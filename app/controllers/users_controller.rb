class UsersController < ApplicationController

  before_filter :set_user

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

end
