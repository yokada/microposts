class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :followings, :followers]
  before_action :check_user, only: [:edit, :update]
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.order(created_at: :desc)
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Welcome to Microposts!"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update(update_user_params)
      flash[:success] = 'Update has succeeded!'
      redirect_to user_path
    else
      flash[:alert] = 'Update has failed.'
      render 'edit'
    end
  end
  
  def followings
    @followings = @user.following_relationships.where(follower_id: @user.id)
    #binding.pry
  end
  
  def followers
    @followers = @user.following_relationships.where(followed_id: @user.id)
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
  
  def update_user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :country, :profile)
  end
  
  def check_user
    redirect_to user_path if @user != current_user
  end
  
  def set_user
    @user ||= User.find(params[:id])
  end
end
