class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  skip_before_action :verify_authenticity_token
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, "hellomars1211")
  end

  def decoded_token
      header = request.headers["Authorization"]
      if header
          token = header.split(" ")[1]
          begin
              JWT.decode(token, "hellomars1211")
          rescue JWT::DecodeError
              nil
          end
      end
  end

  def current_user
    if decoded_token
        user_id = decoded_token[0]["user_id"]
        @user = User.find_by(id: user_id)
    end
  end

  def authorized
    if !current_user
        render json: { message: "Please log in" }, status: :unauthorized
    elsif TokenRev.exists?(val: request.headers["Authorization"].split(" ")[1])
      render json: { message: "Token Revoked" }, status: :unauthorized
    end
  end
end
