module CurrentCart
  extend ActiveSupport::Concern
  
  private
  
  # look for an existing cart
  # if we don't find one, create it
  def set_cart
    # look for cart
    @cart = Cart.find(session[:cart_id])
  rescue ActiveRecord::RecordNotFound
    # exception means we don't find one
    # so we create it
    @cart = Cart.create
    session[:cart_id] = @cart.id
  end
  
end
    