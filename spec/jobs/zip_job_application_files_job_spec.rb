# frozen_string_literal: true

require "rails_helper"

RSpec.describe ZipJobApplicationFilesJob, type: :job do
  it "creates a zip file with the given id linked to a temporary file that contains job application files" do
    job_application_file = create(:job_application_file)
    user = job_application_file.job_application.user
    id = SecureRandom.uuid

    expect {
      ZipJobApplicationFilesJob.new.perform(zip_id: id, user_ids: [user.id])
    }.to change { ZipFile.count }.by(1)

    zip_file = ZipFile.find(id)
    expect(zip_file.zip_url).to be_present

    Zip::File.open(zip_file.zip.current_path) do |zipfile|
      zipfile.first do |file|
        expect(file.size).not_to eq(0)
        expect(file.name).to eq([
          job_application_file.job_application.user.full_name,
          job_application_file.job_application_file_type.name
        ].join(" - "))
      end
    end
  end
end