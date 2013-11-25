module CurrentUser
  extend ActiveSupport::Concern

  private
  
  # check that the user is logged in
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end
  
  # check that the logged in user matches the current user in the session
  # if admin, allow them to edit any user
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user) || admin_user
  end
  
  # check that the current user is an admin user
  def admin_user
      # get current user for session and check if they are an administrator
      check_admin_user = current_user
      return check_admin_user.admin?
  end
  

end