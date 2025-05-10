class AuthController < ApplicationController
  skip_before_action :authorized, only: [ :register, :login ]
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def register
    user = User.create!(user_params)
        @token = encode_token(user_id: user.id)
        render json: {
            user: UserSerializer.new(user),
            token: @token
        }, status: :created
  end

  def me
    render json: current_user, status: :ok
  end

  def login
    @user = User.find_by!(username: login_params[:username])
      if @user.authenticate(login_params[:password])
          @token = encode_token(user_id: @user.id)
          render json: {
              user: UserSerializer.new(@user),
              token: @token
          }, status: :accepted
      else
          render json: { message: "Invalid credential" }, status: :unauthorized
      end
  end

  def logout
    @user = current_user
    if @user
      TokenRev.create!(val: request.headers["Authorization"].split(" ")[1])
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render json: { message: "User not found" }, status: :not_found
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :password, :role)
  end

  def login_params
    params.require(:user).permit(:username, :password, :role)
  end

  def handle_invalid_record(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def handle_record_not_found(e)
    render json: { message: "User doesn't exist" }, status: :unauthorized
  end
end
