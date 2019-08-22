# frozen_string_literal: true

class Admin::Stats::JobApplicationsController < Admin::Stats::BaseController
  before_action :filter_by_full_text, only: %i[index], if: -> { params[:s].present? }
  before_action :fetch_base_ressources, only: %i[index]

  # GET /admin/stats/candidatures
  # GET /admin/stats/candidatures.json
  def index
    @job_applications = @job_applications.where(created_at: date_range)
    @q = @job_applications.ransack(params[:q])
    @job_applications_filtered = @q.result(distinct: true)
                                   .page(params[:page])
                                   .per_page(20)
    @job_applications_count = @job_applications_filtered.count
    build_stats
    build_stats_per_profile
    build_stats_vacancy
  end

  protected

  def root_rel
    @root_rel ||= @q.result(distinct: true).unscope(:order)
  end

  def root_rel_profile
    @root_rel_profile ||= root_rel.joins(:personal_profile)
  end

  def build_stats
    @per_day = root_rel.group_by_day(:created_at, range: date_range).count
    @per_experiences_fit_job_offer = root_rel.group(:experiences_fit_job_offer).count
    @per_rejection_reason = root_rel.group(:rejection_reason_id).count
    @per_state = root_rel.group(:state).count
  end

  def build_stats_per_profile
    @per_gender = root_rel_profile.group(:gender).count
    @per_nationality = root_rel_profile.group(:nationality).count
    @per_has_corporate_experience = root_rel_profile.group(:has_corporate_experience).count
    @per_is_currently_employed = root_rel_profile.group(:is_currently_employed).count
  end

  def build_stats_vacancy
    @per_vacancy = root_rel.joins(:job_offer)
                           .where(job_offers: { published_at: date_range })
                           .where(job_offers: { accepted_job_applications_count: 0 })
                           .group('job_offers.slug')
                           .count
  end

  def filter_by_full_text
    @job_applications = @job_applications.search_full_text(params[:s]).unscope(:order)
  end

  def date_start
    @date_start ||= begin
      res = Date.parse(params[:start]) if params[:start].present?
      res ||= 30.days.ago.beginning_of_day
      res
    end
  end

  def date_end
    @date_end ||= begin
      res = Date.parse(params[:end]) if params[:end].present?
      res ||= Time.current
      res
    end
  end

  def date_range
    date_start..date_end if date_start.present? && date_end.present?
  end

  def fetch_base_ressources
    @employers = Employer.all
    @rejection_reasons = RejectionReason.all
  end
end
