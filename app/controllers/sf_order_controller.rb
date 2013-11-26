class SfOrderController < ApplicationController
  include Databasedotcom::Rails::Controller
  
  include CurrentUser
    
  # error handler for when a cart is requested that doesn't exist
  rescue_from ActiveRecord::RecordNotFound, with: :no_cart_found
  
  def new
    if params[:cart_id].to_i == session[:cart_id].to_i  
      @order = Order__c.new
      @cart = Cart.find(params[:cart_id])
      if signed_in?
        logger.debug "***sf_order->Signed In User Is - #{@current_user.name}"
        # pre-populate order fields from user
        @order.Customer_Name__c = @current_user.name
        @order.Customer_Email__c = @current_user.email
        @order.Customer_Address__c = @current_user.address
      end
    else
      logger.debug "***Cart id Supplied does NOT match session cart id"
      no_cart_found
    end
  end
  
  # create the order
  def create
    # call method to create order and associated order lines
    if create_order
      flash[:success] = "Order Successfully Created. Your reference number is #{@orderReference}"
      if signed_in?
        redirect_to @current_user
      else
        redirect_to root_url
      end
    end
  end
  
  private
  
  def no_cart_found
    logger.error "***Illegal attempt to access cart #{params[:id]} detected..."
    flash[:error] = "You have tried to access a Cart illegally or it doesn't exist!"
    redirect_to products_path
  end
  
  # Create the Order in Salesforce
  def create_order
    # initialize required objects
    @order = Order__c.new
    @cart = Cart.find(session[:cart_id])
    
    # get the Id of the current user to use as the Owner Id
    @dbclient = @order.client
    logger.debug "*** DB Client of type #{@dbclient.class} created for #{@dbclient.user_id}..."
    
    # populate Order Values
    if signed_in?
      @order.Customer_ID__c = @current_user.id
    end
    @order.OwnerId = @dbclient.user_id
    @order.Customer_Name__c = params[:Customer_Name__c]
    @order.Customer_Email__c = params[:Customer_Email__c]
    @order.Customer_Address__c = params[:Customer_Address__c]
    @order.Comments__c = params[:Comments__c]
    @order.Channel__c = "External"
    
    # hacks required to get order into sandbox app - DO NOT include in final code
    @order.Delivered__c = false
                          
    # Save the order to Salesforce
    # if unsuccessful we will return customer to Checkout page and display error
    begin
      
      # call save action on Order to persist it to Salesforce
      # note we get the Salesforce Order Id back if successful
      # which we need for the Order Lines
      @order.save
      
      # save the order lines against order
      @cart.cart_line_items.each do |item|
        # populate fields for Order Line
        order_line = Order_Line__c.new
        order_line.Order__c = @order.Id
        order_line.Order_Line_Item__c = item.sfid
        order_line.Line_Item_Price__c = item.price
        order_line.Quantity__c = item.quantity
        
        # save the Order Line to Salesforce
        order_line.save
      end
      
      # destroy the cart and clear session cart identifier
      @cart.destroy
      session[:cart_id] = nil


    rescue Exception => saveError
      logger.error "***Error Saving Order to Salesforce - #{saveError}"
      # need to use flash.now when calling render action on a page
      flash.now[:error] = "Error Creating Order - #{saveError}"
      render 'new'
      return false
    end
    
    # *******************************
    # get the Order Reference Number
    # *******************************
    
    # query Salesforce for the newly saved order
    @orderNameCollection = @dbclient.query("SELECT Name from Order__c WHERE Order__c.Id = '#{@order.Id}' LIMIT 1")
    # get the Order returned in the collection
    @orderNameElement = @orderNameCollection[0]
    # get the "Name" field from the Order
    @orderReference = @orderNameElement.Name
    
    # if we get here, order is saved successfully
    logger.debug "***Order Reference #{@orderReference} (#{@order.Id}) saved successfully..."
    
    return true
    
  end
  
  
end
