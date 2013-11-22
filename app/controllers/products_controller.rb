class ProductsController < ApplicationController
  include Databasedotcom::Rails::Controller
  
  # very important to get paging working for products list
  require 'will_paginate/array'
  
  # GET products
  def index
    @products = Order_Line_Item__c.all
    # create pagination array to use in view
    # Note that this code works because @products is of
    # type Databasedotcom::Collection which is a subclass
    # of Ruby "Array"
    @products_list = @products.paginate(page: params[:page], per_page: 5)
    # uncomment to print debug information
    #print_product_list_debug
  end
  
  # GET a single product
  def show
    @product = Order_Line_Item__c.find(params[:id])
  end
  
  private
  
  def print_product_list_debug
    logger.debug "*********************************"
    logger.debug "Printing Products List Debug Info"
    logger.debug "*********************************"
    logger.debug "@products is type of #{@products.class}"
    logger.debug "@products superclass is #{@products.class.superclass}"
    logger.debug "@products superclass/superclass is #{@products.class.superclass.class.superclass}"
    logger.debug "Displayed #{@products.total_size} products"
    logger.debug "next_page? = #{@products.next_page?}"
    logger.debug "previous_page = #{@products.previous_page?}"
    logger.debug "client = #{@products.client}"
    logger.debug "current_page_url = #{@products.current_page_url}"
    logger.debug "next_page_url = #{@products.next_page_url}"
    logger.debug "previous_page_url = #{@products.previous_page_url}"
    logger.debug "total_size = #{@products.total_size}"
    
    # print contents of collection
    logger.debug "*** Contents of Product List..."
    @products.each { |x| logger.debug x.Id + "\t" + x.Item_Name__c }
    
    logger.debug "---------- END DEBUG INFO -------"
  end
  
end