class UsersController < ApplicationController
  before_filter :check_login
  authorize_resource

  def new
  	@user = User.new
    authorize! :new, @user
  end

  def edit
  	@user = current_user
    authorize! :edit, @user
  end

  def create
  	@user = User.new(params[:user])
    authorize! :create, @user
    if @user.save
      session[:user_id] = @user.id
      redirect_to home_path, notice: "Thank you for signing up!"
      UserMailer.new_user_msg(@user).deliver
      flash[:notice] = "#{@user.proper_name} has been added to the system and notified by email."
    else
      flash[:error] = "This user could not be created."
      render "new"
    end
  end

  def update
    @user = current_user
    authorize! :update, @user
    if @user.update_attributes(params[:user])
      flash[:notice] = "User is updated."
      redirect_to @user
    else
      render :action => 'edit'
    end
  end
end
