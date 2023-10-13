# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Settings::JobOfferTerms" do
  it_behaves_like "an admin setting", :job_offer_term, :name, "a new name"
  it_behaves_like "a movable admin setting", :job_offer_term
end
