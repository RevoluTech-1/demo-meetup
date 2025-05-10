class HomeController < ApplicationController
    def index
        return render json: { message: "Welcome to the API" }, status: :ok
    end

    def show
        ruby = params[:id]

        render json: { message: "Hello #{ruby}" }, status: :ok
    end
end
