class SfOrderController < ApplicationController
  
  include CurrentUser
    
  # error handler for when a cart is requested that doesn't exist
  rescue_from ActiveRecord::RecordNotFound, with: :no_cart_found
  
  # user has checked out
  def new
    if params[:cart_id].to_i == session[:cart_id].to_i  
      @cart = Cart.find(params[:cart_id])
      @Comments__c = ''
      if signed_in?
        logger.debug "***sf_order->Signed In User Is - #{@current_user.name}"
        # pre-populate order fields from user
        @Customer_Name__c = @current_user.name
        @Customer_Email__c = @current_user.email
        @Customer_Address__c = @current_user.address
      else
        @Customer_Name__c = ''
        @Customer_Email__c = ''
        @Customer_Address__c = ''
      end
    else
      logger.debug "***Cart id Supplied does NOT match session cart id"
      no_cart_found
    end
  end
  
  # user selected "Create Order" at "Checkout" screen
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
    @cart = Cart.find(session[:cart_id])
    
    # get the Id of the current user to use as the Owner Id
    client = Force.new
    auth_hash = client.authenticate!
    idPath = auth_hash[:id]
    logger.debug("***idPath = #{idPath}...")
    ownerId = idPath.slice((idPath.rindex('/')+1)..idPath.length)
    logger.debug("***Record Owner = #{ownerId}...")
    
    # populate Order Values
    if signed_in?
      customer_ID__c = @current_user.id
    else
      customer_ID__c = ''
    end
    customer_Name__c = params[:Customer_Name__c]
    customer_Email__c = params[:Customer_Email__c]
    customer_Address__c = params[:Customer_Address__c]
    comments__c = params[:Comments__c]
    channel__c = "External"
    delivered__c = false
                          
    # Save the order to Salesforce
    # if unsuccessful we will return customer to Checkout page and display error
    begin
      
      # call client.create action to persist Order to Salesforce
      # note we get the Salesforce Order Id back if successful
      # which we need for the Order Lines            
      orderId = client.create!('Order__c', OwnerId: ownerId, Customer_ID__c: customer_ID__c,
                                  Customer_Name__c: customer_Name__c,
                                  Customer_Email__c: customer_Email__c,
                                  Customer_Address__c: customer_Address__c,
                                  Comments__c: comments__c,
                                  Channel__c: channel__c,
                                  Delivered__c: delivered__c)
      
      logger.debug("***Successfully created Order #{orderId}")
      
      # save the order lines against order
      @cart.cart_line_items.each do |item|
        order_Line_Item__c = item.sfid
        order_Line_Item_Price__c = item.price
        order_Line_Quantity__c = item.quantity
        
        client.create('Order_Line__c', Order__c: orderId, 
                                        Order_Line_Item__c: order_Line_Item__c,
                                        Line_Item_Price__c: order_Line_Item_Price__c,
                                        Quantity__c: order_Line_Quantity__c)
      end
      
      logger.debug("***Successfully created Order Lines for #{orderId}")
      
      # *******************************
      # get the Order Reference Number
      # *******************************
    
      # query Salesforce for the newly saved order
      orderNameCollection = client.query("SELECT Name from Order__c WHERE Order__c.Id = '#{orderId}' LIMIT 1")
      # get the Order returned in the collection
      orderNameElement = orderNameCollection.first
      # get the "Name" field from the Order
      @orderReference = orderNameElement.Name
    
      # if we get here, order is saved successfully
      logger.debug "***Order Reference #{@orderReference} (#{orderId}) saved successfully..."
      
      
      # destroy the cart and clear session cart identifier
      @cart.destroy
      session[:cart_id] = nil


    rescue Exception => saveError
      logger.error "***Error Saving Order to Salesforce - #{saveError}"
      # need to use flash.now when calling render action on a page
      @Customer_Name__c = customer_Name__c
      @Customer_Email__c = customer_Email__c
      @Customer_Address__c = customer_Address__c
      @Comments__c = comments__c
      flash.now[:error] = "Error Creating Order - #{saveError}"
      render 'new'
      return false
    end
      
    # everything saved successfully and cart destroyed
    return true
    
  end
  
  
end
