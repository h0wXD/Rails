class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Micropost created!'
    end
    @feed_items = current_user.feed_paginate(params)
    respond_to do |format|
      format.html { redirect_to root_url }
      format.js
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = 'Micropost deleted'
    @feed_items = current_user.feed_paginate(params)
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
  end

private
  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url if @micropost.nil?
  end
end
