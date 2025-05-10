class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]
  rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

  def index
    # GET http://localhost:3000/posts?search=rails&user_id=1&sort_by=created_at&order=desc
    if current_user.role == 1
      @posts = Post.all
    else
      @posts = Post.all.where(user_id: current_user.id)
    end

    if params[:search].present?
      @posts = @posts.where("title LIKE ? OR content LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    @posts = @posts.where(user_id: params[:user_id]) if params[:user_id]

    if params[:sort_by].present? && params[:order].present?
      @posts = @posts.order("#{params[:sort_by]} #{params[:order]}")
    end

    #render json: @posts
    render json: @posts.map { |p| p.as_json.merge(file_url: p.image.attached? ? url_for(p.image) : nil) }  end

  def show
    file_url = rails_blob_path(@post.image, disposition: "attachment") if @post.image.attached?
    render json: { post: @post, file_url: file_url }
  end

  def create
    @post = Post.new(post_params.merge(user: current_user))
    @post.image.attach(post_params[:image]) if post_params[:image].present?
    if @post.save
      render json: @post, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    head :no_content
  end

  private

  def set_post
    if current_user.role == 1
      @post = Post.find(params[:id])
    else
      @post = Post.find_by(id: params[:id], user_id: current_user.id)
    end
  end

  def post_params
    params.permit(:title, :content, :image)
  end

  def handle_invalid_record(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def handle_record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end
end
