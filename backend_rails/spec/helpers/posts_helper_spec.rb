require "rails_helper"

RSpec.describe PostsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:token) { encode_token(user_id: user.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  before { request.headers.merge!(headers) }

  describe "GET #index" do
    it "returns posts for current user" do
      FactoryBot.create(:post, user: user, title: "Test Post")
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).first["title"]).to eq("Test Post")
    end

    it "filters posts by search" do
      FactoryBot.create(:post, user: user, title: "Rails Post")
      FactoryBot.create(:post, user: user, title: "Other")
      get :index, params: { search: "Rails" }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
      expect(JSON.parse(response.body).first["title"]).to eq("Rails Post")
    end
  end

  describe "POST #create" do
    let(:valid_params) { { title: "New Post", content: "Content" } }

    it "creates a new post" do
      post :create, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["title"]).to eq("New Post")
    end
  end
end
