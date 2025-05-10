require "rails_helper"

RSpec.describe AuthController, type: :controller do
  describe "POST #register" do
    let(:valid_params) { { user: { username: "newuser", password: "password123" } } }
    let(:invalid_params) { { user: { username: "", password: "" } } }

    it "creates a new user with valid params" do
      post :register, params: valid_params
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["user"]["username"]).to eq("newuser")
      expect(JSON.parse(response.body)["token"]).to be_present
    end

    it "returns errors with invalid params" do
      post :register, params: invalid_params
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)["errors"]).to include("Username can't be blank")
    end
  end

  describe "POST #login" do
    let(:user) { FactoryBot.create(:user, username: "testuser", password: "password123") }
    let(:valid_params) { { user: { username: "testuser", password: "password123" } } }
    let(:invalid_params) { { user: { username: "testuser", password: "wrong" } } }

    it "logs in with valid credentials" do
      post :login, params: valid_params
      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)["user"]["username"]).to eq("testuser")
      expect(JSON.parse(response.body)["token"]).to be_present
    end

    it "rejects invalid credentials" do
      post :login, params: invalid_params
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)["message"]).to eq("Invalid credential")
    end
  end

  describe "GET #me" do
    let(:user) { FactoryBot.create(:user) }
    let(:token) { encode_token(user_id: user.id) }
    let(:headers) { { "Authorization" => "Bearer #{token}" } }

    before { request.headers.merge!(headers) }

    it "returns current user" do
      get :me
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["username"]).to eq(user.username)
    end
  end
end