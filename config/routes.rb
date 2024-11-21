# frozen_string_literal: true

require "sidekiq/web"

# Handle multi-submit form
class CommitParamConstraint
  def initialize(*param_values)
    @param_values = param_values
  end

  def matches?(request)
    @param_values.any? { |prm| request.params[:commit] == prm.to_s }
  end
end

Rails.application.routes.draw do
  # Dynamic error pages
  get "/404", to: "application#resource_not_found", via: :all
  get "/500", to: "application#internal_error", via: :all

  get "/accessibilite", to: redirect("/pages/declaration-d-accessibilite")
  get "/mentions-legales", to: redirect("/pages/mentions-legales")
  get "/cgu", to: redirect("/pages/conditions-generales-d-utilisation")
  get "/politique-confidentialite", to: redirect("/pages/politique-de-confidentialite")
  get "/suivi", to: redirect("/pages/suivi-d-audience-et-vie-privee")

  # Domains check
  get "/.well-known/pki-validation/:file_name" => "domain_validations#show", :as => :domain_validations

  as :administrator do
    patch "/admin/confirmation" => "administrators/confirmations#update", :as => :update_administrator_confirmation
  end
  devise_for :administrators, path: "admin", controllers: {
    confirmations: "administrators/confirmations",
    sessions: "administrators/sessions"
  }
  devise_for :users, controllers: {
    registrations: "users/registrations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    get "/users/sign_up/success" => "users/registrations#success", :as => :success_user_registration
  end

  namespace :admin do
    authenticate :administrator do
      mount Sidekiq::Web => "/sidekiq"
      mount MaintenanceTasks::Engine => "/maintenance_tasks"
    end

    resource :account do
      member do
        get :change_email, :change_password, :photo
        patch :update_email, :update_password
      end
    end
    resources :salary_ranges, only: %i[index]
    resources :email_templates, only: %i[index] do
      collection do
        get :pick
      end
    end
    resources :job_offer_terms, only: %i[index]
    resources :job_offers, path: "offresdemploi" do
      collection do
        post :exports, :feature
        post :init, to: "job_offers#new"
        get :init, to: "job_offer_terms#index"
        get :add_actor, :featured, :archived
        JobOffer.aasm.events.map(&:name).each do |event_name|
          action_name = :"create_and_#{event_name}"
          post :create, constraints: CommitParamConstraint.new(action_name), action: action_name
        end
      end
      member do
        get :export, :board, :stats, :new_transfer, :new_send
        post :transfer, :feature, :unfeature, :send_to_list
        JobOffer.aasm.events.map(&:name).each do |event_name|
          patch(event_name.to_sym)
          action_name = :"update_and_#{event_name}"
          patch :update, constraints: CommitParamConstraint.new(action_name), action: action_name
        end
        namespace :job_offers do
          resources :readings, only: :create
        end
      end
      resources :job_applications, path: "candidatures" do
        member do
          get :cvlm
          get :files
          get :emails
        end
      end
      resources :archives, only: [:new, :create]
      resources :multiple_recipients_emails, only: %i[new create]
      resources :recipients, only: %i[index create]
    end
    resources :preferred_users, only: :destroy
    resources :preferred_users_lists, path: "liste-candidats" do
      member do
        get :export
        post :send_job_offer
      end
      resources :preferred_users
    end
    resources :users, path: "candidats", except: %i[create] do
      resource :resume, only: %i[show]
      collection do
        post :multi_select
      end
      member do
        get :listing, :photo
        put :update_listing
        post :suspend, :unsuspend, :send_job_offer
      end
    end
    resources :job_applications, path: "candidatures", only: %i[index show update] do
      member do
        patch :change_state
      end
      resources :job_application_files do
        member do
          post :check
          post :uncheck
        end
      end
      resources :messages, only: %i[create]
      resources :emails, only: %i[create] do
        member do
          post :mark_as_read, :mark_as_unread
          get :attachment
        end
      end
    end
    resources :zip_files, only: :show
    namespace :stats do
      root to: "job_applications#index"
      get :job_offers, to: "job_offers#index"
      resources :job_applications, path: "candidatures", only: %i[index]
    end
    namespace :settings, path: "parametres" do
      resource :positions, only: :update
      resource :organization do
        member do
          get :edit_security
          patch :update_general, :update_display, :update_security
        end
      end
      resources :organization_defaults
      resources :frequently_asked_questions do
        member do
          post :move_higher, :move_lower
        end
      end

      resources :pages do
        member do
          post :move_higher, :move_lower
        end
      end
      resources :cmgs do
        member do
          post :move_higher, :move_lower
        end
      end
      resources :administrators, path: "administrateurs" do
        collection do
          get :export
          get :inactive
        end
        member do
          post :resend_confirmation_instructions
          post :send_unlock_instructions
          post :deactivate
          post :reactivate
          post :transfer
        end
      end
      resources :employers, :categories do
        member do
          post :move_left, :move_right
        end
      end
      resources :salary_ranges
      resources :job_application_file_types
      other_settings = %i[
        availability_ranges
        archiving_reasons benefit drawbacks bops email_template job_application_file_types rejection_reasons
        contract_duration foreign_languages foreign_language_levels job_offer_terms user_menu_links
      ]
      (JobOffer::SETTINGS + other_settings).each do |setting|
        resources setting.to_s.pluralize.to_sym, except: %i[show] do
          member do
            post :move_higher, :move_lower
          end
        end
      end
      root to: "administrators#index"
    end
    root to: "job_offers#index"
  end

  authenticate :user do
    namespace "account", path: "espace-candidat" do
      resource :profiles, path: "mon-profil", only: [] do
        resource :resume, only: :show
        collection do
          get :edit
          patch :update
        end
      end
      resources :job_applications, path: "mes-candidatures" do
        member do
          get :job_offer, path: "offre"
          get :profile
        end
        resources :job_application_files, path: "documents"
        resources :emails, only: %i[index create] do
          member do
            get :attachment
          end
        end
      end
      resource :user, path: "mon-compte", only: %i[show destroy] do
        collection do
          get :edit
          patch :update
        end
        member do
          get :change_email, :change_password, :photo
          patch :update_email, :update_password, :unlink_france_connect, :set_password
        end
      end
    end
  end

  resources :job_offers, path: "offresdemploi", only: %i[index show] do
    collection do
      get :apply
    end
    member do
      get :apply, to: "job_offers#old_apply"
      post :send_application
      get :successful
      resources :bookmarks, only: %i[create destroy], path: "favoris"
    end
  end

  resources :pages, only: %w[show]
  resource :robots, only: %w[show]
  resource :sitemap

  root to: "homepages#show"
end
