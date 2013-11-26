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
    
end