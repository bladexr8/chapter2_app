class UsersController < ApplicationController
  
  require 'will_paginate/array'
  
  # include utilies for checking user authentication
  include CurrentUser
  
  #include CustomerOrder
  
  # a before action filter to ensure that user is signed
  # in before the "edit" and "update" actions
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :show]
  
  # a before action filter to ensure that user can only see/edit
  # their own details
  before_action :correct_user, only: [:edit, :update, :show]
  
  # show users index page using pagination
  # paginate method (from pagination support gems, refer to Gemfile)
  # takes :page hash argument and pulls users one chunk at a time
  # (default value is 30), e.g. page 1 = 1 - 30, page 2 = 31 - 60.
  # If page is nil, paginate will return first page
  # can also use order: to order records, e.g. order: 'name ASC'
  def index
    # only administrators can access this page
    if admin_user
      @users = User.paginate(page: params[:page], per_page: 25)
    else
      flash[:error] = "You do not have administrative access."
      redirect_to(root_url)
    end
  end
  
  # delete a user (admin only)
  def destroy
    if admin_user
      User.find(params[:id]).destroy
      flash[:success] = "User has been deleted"
      redirect_to users_url
    else
      flash[:error] = "You do not have administrative access."
      redirect_to(root_url)
    end      
  end
  
  # create a new user
  def new
    @user = User.new
  end
  
  # show the user profile page
  def show
    # find logged in user
    @user = User.find(params[:id])
    # get summary of Order from Salesforce by calling utility class in config/initializers folder
    @customerOrderUtility = CustomerUtility::CustomerOrder.new
    @customerOrderSummary = @customerOrderUtility.getCustomerOrderSummary(@user.id)
    @customerOrderList = @customerOrderSummary.to_a.paginate(page: params[:page], per_page: 5)
  end
  
  # display page to edit logged in user
  def edit
    # we don't need the following line because it is
    # taken care of by the before_action filter
    # @user = User.find(params[:id])
  end
  
  # from the edit page, update the user details
  def update
    # we don't need the following line because it is
    # taken care of by the before_action filter
    # @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # Handle successful update
      flash[:success] = "Profile successfully updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  # create a new user in the database
  def create
    # use custom initialization hash as a security measure
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Force E-Commerce App!"
      # redirect user to their profile page
      redirect_to @user
    else
      render 'new'
    end
  end
  
  # Private methods
  private
  
  # initialization hash to protect against attribute injection attacks
  def user_params
    # only allow the attributes specified to be passed in
    # from client(s). This guards against maliciious attacks
    # from clients such as cURL that can inject extra attributes
    # such as "isAdmin = true"
    params.require(:user).permit(:name, :email, :password, :address,
                                  :password_confirmation)
  end
    
end
