class CartLineItemsController < ApplicationController
  # include utilities to locate a cart (or create one)
  # for the current session
  include CurrentCart
  before_action :set_cart, only: [:create]
  before_action :set_line_item, only: [:show, :edit, :update, :destroy]
  
  # create a new CartLineItem when "Add to Cart" link clicked
  def create
    logger.debug "***Creating a New Cart Line Item for #{params[:product_id]}, #{params[:desc]}, price #{params[:price]}"
    logger.debug "***Current Cart id Is - #{@cart.id}"
    logger.debug "***Current Products List Page Is - #{params[:current_page]}"
    # create or increment existingvCartLineItem
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
    
end
