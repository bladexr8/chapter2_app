class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    # use custom initialization hash as a security measure
    @user = User.new(user_params)
    if @user.save                   # not final implementation!
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
    params.require(:user).permit(:name, :email, :password,
                                  :password_confirmation)
  end
  
end
