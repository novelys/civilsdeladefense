# frozen_string_literal: true

class Admin::JobApplicationsController < Admin::BaseController
  # GET /admin/candidatures
  # GET /admin/candidatures.json
  def index
    @contract_types = ContractType.all
    @employers = Employer.tree
    @preferred_users_lists = current_administrator.preferred_users_lists

    @job_applications = @job_applications.includes(:job_offer, :user)
    @q = @job_applications.ransack(params[:q])
    @job_applications_filtered = @q.result.yield_self { |relation|
      if params[:s].present?
        relation.search_full_text(params[:s])
      else
        relation
      end
    }.yield_self { |relation|
      relation.paginate(page: params[:page], per_page: 25)
    }
    build_employer_ids

    render action: :index, layout: "admin/pool"
  end

  # GET /admin/candidatures/1
  # GET /admin/candidatures/1.json
  def show
    user = @job_application.user
    if user.blank?
      redirect_to admin_job_offer_path(@job_application.job_offer), notice: t(".user_deleted")
    else
      @other_job_applications = user && user.job_applications.where.not(id: @job_application.id)
      render action: :show, layout: layout_choice
    end
  end

  alias_method :cvlm, :show
  alias_method :emails, :show
  alias_method :files, :show

  # PATCH/PUT /admin/candidatures/1
  # PATCH/PUT /admin/candidatures/1.json
  def update
    respond_to do |format|
      if @job_application.update(job_application_params)
        format.html { redirect_to [:admin, @job_application], notice: t(".success") }
        format.js do
          @notification = t(".success")
          render :update
        end
      else
        format.html { render :edit }
        format.js do
          @notification = t(".failure")
          render :update, status: :unprocessable_entity
        end
      end
    end
  end

  def change_state
    @state = params[:state] || params.dig(:job_application, :state)
    known_aasm_state = @job_application.aasm.states.detect { |s| s.name.to_s == @state }
    raise ForbiddenState.new(state: @state) if known_aasm_state.nil?

    @job_application.send(:"#{known_aasm_state.name}!")
    @job_offer = @job_application.job_offer
    state_i18n = JobApplication.human_attribute_name("state/#{@state}")

    current_max = @job_offer.current_most_advanced_job_applications_state
    if @job_offer.most_advanced_job_applications_state_before_type_cast != current_max
      @job_offer.update(most_advanced_job_applications_state: current_max)
    end

    @notification = t(".success", state: state_i18n)
    render_reponse
  rescue ActiveRecord::RecordInvalid
    @notification = @job_application.errors.messages[:state].join(" ")
    render_reponse
  end

  def render_reponse
    respond_to do |format|
      format.html do
        redirect_back(fallback_location: [:admin, @job_application], notice: @notification)
      end
      format.js do
        render :change_state
      end
      format.json { render :show, status: :ok, location: @job_application }
    end
  end

  private

  def set_job_application = @job_application = JobApplication.find(params[:id])

  def job_application_params
    params.require(:job_application).permit(:skills_fit_job_offer, :experiences_fit_job_offer, :rejection_reason_id)
  end

  def layout_choice
    if params[:job_offer_id].present?
      @job_offer = JobOffer.find(params[:job_offer_id])
      @layout_full_width = true
      request.xhr? ? false : "admin/job_offer_single"
    else
      request.xhr? ? false : "admin/pool"
    end
  end

  def build_employer_ids
    @employer_ids = @job_applications_filtered.map(&:employer_id).uniq
  end
end
