# frozen_string_literal: true

module Maintenance
  class PopulateResumesTask < MaintenanceTasks::Task
    include Rails.application.routes.url_helpers

    def collection = Profile.where(profileable_type: "User", resume_file_name: [nil, ""])

    def process(profile)
      job_application = profile.profileable.last_job_application
      return if job_application.blank?

      job_application_file_type = JobApplicationFileType.find_by(name: "CV")
      return if job_application_file_type.blank?

      job_application_file = job_application.job_application_files.find_by(job_application_file_type:)
      return if job_application_file.blank?

      update_resume(profile, job_application_file)
    end

    delegate :count, to: :collection

    private

    def update_resume(profile, job_application_file)
      file = Tempfile.new([job_application_file.content_file_name.gsub(".pdf", ""), ".pdf"])
      file.binmode
      file.write(job_application_file.document_content.read)
      file.rewind

      profile.update!(resume: file)

      file.close
      file.unlink
    end
  end
end
