module SessionsHelper
  
  # handle user sign-in from /signin page
  def sign_in(user)
    # create a new toke
    remember_token = User.new_remember_token
    # place the unencrypted token in the browser cookies
    cookies.permanent[:remember_token] = remember_token
    # save the encrypted token to the database
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    # set the current user equal to the given user
    self.current_user = user
  end
  
  # sign out a logged in user
  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end
  
  # return flag to indicate if user is logged in
  def signed_in?
    !current_user.nil?
  end
  
  # setter for current user property
  def current_user=(user)
    @current_user = user
  end
  
  # getter for current user
  def current_user
    # encrypt token from user cookie
    remember_token = User.encrypt(cookies[:remember_token])
    # if we match the encrypted token to a user the assign user to property
    # this line only called if @user is undefined to reduce load on DB
    @current_user ||= User.find_by(remember_token: remember_token)
  end
  
  # check that the logged in user matches the current user in the session
  def current_user?(user)
    user == current_user
  end
  
  # code to support friendly forwarding after a user logs in
  
  # store the location to redirect the user to after they
  # are authenticated
  def store_location
    session[:return_to] = request.url if request.get?
  end
  
  # perform the redirection after user is authenticated
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end
  
end
