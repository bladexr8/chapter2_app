class CartController < ApplicationController
  
  # include cart creation/detection utilities
  include CurrentCart
  
  # make sure we hae an existing cart or create one
  before_action :set_cart, only: [:show, :edit, :update, :destroy]
  
  # error handler for when a cart is requested that doesn't exist
  rescue_from ActiveRecord::RecordNotFound, with: :no_cart_found
  
  # display the cart contents
  def show
    @cart = Cart.find(params[:id])
    # if the cart doesn't exist in the session, log a potential
    # security breach and re-direct user
    if @cart.id != session[:cart_id]
      logger.error "***Illegal access attempt for cart #{params[:id]}"
      flash[:error] = "You have tried to access a Cart illegally or it doesn't exist!"
      redirect_to products_path
    end
  end
  
  # empty the cart
  def destroy
    logger.debug "***Destroying cart #{session[:cart_id]}"
    # if the cart passed in is the cart held in the session
    # then delete it. Note that this automatically destroys
    # all line items as well
    if @cart.id == session[:cart_id]
      @cart.destroy
      session[:cart_id] = nil
    end
    flash[:success] = "Your Cart is now empty"
    redirect_to products_path
  end
  
  private
  
  def no_cart_found
    logger.error "***Illegal attempt to access cart #{params[:id]} detected..."
    flash[:error] = "You have tried to access a Cart illegally or it doesn't exist!"
    redirect_to products_path
  end
    
end
