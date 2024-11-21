# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Settings::PositionsController do
  before { sign_in create(:administrator) }

  describe "Changing a setting position" do
    subject(:update_request) { patch admin_settings_positions_path(params) }

    let(:params) do
      {
        resource_id: resource.id,
        resource_class: resource.class.to_s,
        position: position,
        sibling_resource_id: sibling_resource_id
      }
    end

    context "when resource acts as a nested set" do
      let!(:resource) { create(:category) }
      let(:position) { nil }

      before { create(:category) }

      context "when moving to the end" do
        let(:sibling_resource_id) { nil }

        it { expect { update_request }.to change { resource.reload.lft } }

        it { expect { update_request }.to change { resource.reload.rgt } }
      end

      context "when moving next to a sibling" do
        let!(:sibling_resource_id) { create(:category).id } # rubocop:disable RSpec/LetSetup

        it { expect { update_request }.to change { resource.reload.lft } }

        it { expect { update_request }.to change { resource.reload.rgt } }
      end
    end

    context "when resource acts as a list" do
      let!(:resource) { create(:benefit) }
      let(:position) { 2 }
      let(:sibling_resource_id) { nil }

      before { create(:benefit) }

      it { expect { update_request }.to change { resource.reload.position }.from(1).to(2) }

      describe "response" do
        before { update_request }

        it { expect(response).to have_http_status(:ok) }
      end
    end
  end
end
