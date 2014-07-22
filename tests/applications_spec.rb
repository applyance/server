ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'factory_girl'

require_relative '_config'
require_relative '_helpers'
require_relative '_factories'

describe Applyance::Application do

  include Rack::Test::Methods
  include Applyance::Test::Helpers

  before(:all) do
  end
  after(:each) do
    app.db[:accounts_roles].delete
    app.db[:accounts].delete
    app.db[:admins].delete
    app.db[:entities].delete
    app.db[:blueprints].delete
    app.db[:definitions].delete
    app.db[:datums].delete
    app.db[:fields].delete
    app.db[:domains].delete
    app.db[:reviewers].delete
    app.db[:units].delete
    app.db[:spots].delete
    app.db[:applications].delete
  end
  after(:all) do
  end

  def account_auth
    header "Authorization", "ApplyanceLogin auth=#{account.api_key}"
  end

  shared_examples_for "a single application" do
    it "returns the information for application show" do
      expect(json.keys).to contain_exactly('id', 'spots', 'fields', 'submitter', 'digest', 'submitted_from', 'stage', 'submitted_at', 'last_activity_at', 'created_at', 'updated_at')
    end
  end

  shared_examples_for "multiple applications" do
    it "returns the information for application index" do
      expect(json.first.keys).to contain_exactly('id', 'spots', 'submitter', 'digest', 'submitted_from_id', 'stage', 'submitted_at', 'last_activity_at', 'created_at', 'updated_at')
    end
  end

  # Create application
  describe "POST #applications" do
    context "not logged in" do
      let(:definition_obj) { create(:definition, :label => "Question 1")}
      let(:datum_obj) { create(:datum) }
      let(:blueprint) { create(:blueprint_with_spot) }

      before(:each) do

        application_request = {
          submitter: {
            name: "Stephen Watkins",
            email: "stjowa@gmail.com"
          },
          submitted_from: {
            lat: 30.5,
            lng: -40.2
          },
          spot_ids: [blueprint.spot.id],
          fields: [
            {
              datum: {
                detail: "Answer...",
                definition: {
                  label: "Question 1",
                  description: "Description...",
                  type: "text"
                }
              }
            },
            {
              datum: {
                definition_id: definition_obj.id,
                detail: "Answer 2..."
              }
            },
            {
              datum: {
                id: datum_obj.id,
                detail: "Answer 5..."
              }
            },
            {
              datum_id: datum_obj.id
            }
          ]
        }

        post "/applications", Oj.dump(application_request), { "CONTENT_TYPE" => "application/json" }
      end

      it_behaves_like "a created object"
      it_behaves_like "a single application"
    end
  end

  # Remove application
  describe "Delete #application" do
    context "logged in as admin" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.spots.first.unit.reviewers.first.account.api_key}"
        delete "/applications/#{application.id}"
      end

      it_behaves_like "a deleted object"
      it_behaves_like "an empty response"
    end
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) { delete "/applications/#{application.id}" }

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve applications
  describe "GET #spot/applications" do
    context "logged in as reviewer" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.spots.first.unit.reviewers.first.account.api_key}"
        get "/spots/#{application.spots.first.id}/applications"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple applications"
    end
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) do
        get "/spots/#{application.spots.first.id}/applications"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve unit applications
  describe "GET #unit/applications" do
    context "logged in as reviewer" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.spots.first.unit.reviewers.first.account.api_key}"
        get "/units/#{application.spots.first.unit.id}/applications"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "multiple applications"
    end
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) do
        get "/units/#{application.spots.first.unit.id}/applications"
      end

      it_behaves_like "an unauthorized account"
    end
  end

  # Retrieve one application
  describe "GET #application" do
    context "logged in" do
      let(:application) { create(:application) }
      before(:each) do
        header "Authorization", "ApplyanceLogin auth=#{application.submitter.api_key}"
        get "/applications/#{application.id}"
      end

      it_behaves_like "a retrieved object"
      it_behaves_like "a single application"
    end
    context "not logged in" do
      let(:application) { create(:application) }
      before(:each) do
        get "/applications/#{application.id}"
      end

      it_behaves_like "an unauthorized account"
    end
  end

end
