class ProductsController < ApplicationController
  
  # very important to get paging working for products list
  require 'will_paginate/array'
  
  # GET products
  def index    
    # using Heroku1 force.rb gem (https://github.com/heroku/force.rb)
    logger.debug "***Using force.rb gem to get Product Information..."
    
    # initialize force.rb client
    forceClient = Force.new
    
    # issue force.rb query to retrieve products
    @products = forceClient.query("select Id, Item_Name__c, Capacity__c, Unit_Price__c,
                                         Induction__c, Power_Output__c, Torque__c   
                                         from Order_Line_Item__c 
                                         order by Item_Name__c ASC")
    
    # convert products returned from force.rb to an array and set up bootstrap pagination
    @products_list = @products.to_a.paginate(page: params[:page], per_page: 5)
    
    logger.debug "***Retrieved Product Information using force.rb gem"
        
  end
  
  # GET a single product
  def show
    @product = Order_Line_Item__c.find(params[:id])
  end
    
end