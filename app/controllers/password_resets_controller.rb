class PasswordResetsController < ApplicationController
  # REVIEW: Are these methods always orderly executed?
  before_action :get_user_with_validation, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new
  end

  def edit
    get_user unless @user
    @user.reset_token = params[:id]
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def update
    get_user unless @user
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)
      set_log_in_session(@user)
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def get_user_with_validation
    get_user unless @user
    unless (@user&.activated? && @user&.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  def check_expiration
    get_user unless @user
    if @user.password_reset_expired?
      flash[:danger] = 'Password reset has expired'
      redirect_to new_password_reset_url
    end
  end
end
