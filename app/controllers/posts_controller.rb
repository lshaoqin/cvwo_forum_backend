class PostsController < ApplicationController
  def post_params
    params.require(:title, :user_id).permit(:body)
  end

  def index
    posts = Post.all
    render json: posts
  end

  def create
    #First, check if a valid user_id token was supplied
    begin 
      decoded_id = JWT.decode!(params[:token], Rails.application.credentials.secret_key).payload
    rescue JWT::VerificationError
      render json: {errors: "Invalid user token"}
    end
    #Create post if token was valid
    @post = Post.create(title: params[:title], body: params[:body], user_id: decoded_id[:user_id])
      if @post.save
          render json: @post, status: :created
      else
          render json: {errors: post.errors}, status: :unprocessable_entity
      end
  end

  def edit
  end
end