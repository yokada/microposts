class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create]

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Microposts created!'
      redirect_to root_url
    else
      @feed_items = current_user.feed_items.includes(:user).order(created_at: :desc)
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost = current_user.microposts.find_by(id: params[:id])
    return redirect_to root_url unless @micropost

    @micropost.destroy
    flash[:success] = 'Micropost has been deleted.'
    redirect_to request.referer || root_url
  end

  def retweet
    retweet_post = Micropost.find(params[:id])
    @micropost = current_user.microposts.build()
    @micropost.content = retweet_post.content
    @micropost.retweet_id = retweet_post.id
    if @micropost.save
      flash[:success] = 'Retweet succeeded'
      redirect_to root_url
    else
      flash[:danger] = 'Retweet failed!'
      redirect_to root_url
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
