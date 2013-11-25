class CartLineItemsController < ApplicationController
  # include utilities concern to locate a cart (or create one)
  # for the current session
  include CurrentCart
  before_action :set_cart, only: [:create]
  before_action :set_line_item, only: [:edit, :destroy]
  
  # error handler for when a cart line item is requested that doesn't exist
  rescue_from ActiveRecord::RecordNotFound, with: :no_cart_line_item_found
  
  # create a new CartLineItem when "Add to Cart" link clicked
  def create
    # create or increment existing CartLineItem
    @line_item = add_line_item
    # save CartLineItem and create flash message indicating result
    if @line_item.save
      flash[:success] = "#{params[:desc]} Successfully Added to Cart"
    else
      flash[:error] = "#{params[:desc]} not Added to Cart - Please contact Support"
    end
    # redirect back to Products page to allow user to continue shopping
    if params[:current_page] == 1
      logger.debug "*** Redirecting to First Products Page..."
      redirect_to products_path
    else
      logger.debug "Redirecting to Products Page #{params[:current_page]}"
      redirect_to products_path(page: params[:current_page])
    end
  end
  
  def add_line_item
    # search for existing line item for product
    current_item = @cart.cart_line_items.find_by(sfid: params[:product_id])
    if current_item
      # if we find existing line, increment it by 1
      current_item.quantity += 1
    else
      # build a new line
      # create CartLineItem and link it to current cart
      current_item = CartLineItem.new
      current_item.cart_id = @cart.id
      current_item.sfid = params[:product_id]
      current_item.name = params[:desc]
      current_item.price = params[:price]
    end
    return current_item    
  end
  
  # destroy a line item
  def destroy
    # make sure user is accessing cart currently
    # held in their session
    if params[:id].to_i == session[:cart_id].to_i
      logger.debug "***Destroying line item #{params[:line_id]}..."
      @cart_line_item.destroy
      flash[:success] = "Item successfully removed from Cart"
      redirect_to cart_path(session[:cart_id])
    else
      logger.debug "***Cart id Supplied does NOT match session cart id"
      no_cart_line_item_found
    end
  end
  
  # edit a line item
  def edit
    # make sure user is accessing cart currently
    # held in their session
    if params[:id].to_i == session[:cart_id].to_i
      logger.debug "***Editing line item #{params[:line_id]}..."
    else
      logger.debug "***Cart id Supplied does NOT match session cart id"
      no_cart_line_item_found
    end       
  end
  
  # update line item in database after it is edited
  def update
    logger.debug "***Updating Line Item #{params[:id]} quantity to #{params[:cart_line_item][:quantity]}"
    @cart_line_item = CartLineItem.find(params[:id])
    @cart_line_item.quantity = params[:cart_line_item][:quantity]
    if @cart_line_item.save
      flash[:success] = "Cart Item successfully updated"
    else
      flash[:error] = "Cart Item update unsuccessful"
    end
    redirect_to cart_path(session[:cart_id])
  end
  
  private
   
  def set_line_item
    # find line item passed in
    @cart_line_item = CartLineItem.find(params[:line_id])
  end
  
  def no_cart_line_item_found
    logger.error "***Illegal attempt to access cart line item #{params[:line_id]} detected..."
    flash[:error] = "You have tried to access a Cart line item illegally or it doesn't exist!"
    redirect_to products_path
  end
  
    
end
