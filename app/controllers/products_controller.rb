class ProductsController < ApplicationController
  include Databasedotcom::Rails::Controller
  
  # GET products
  def index
    @products = Order_Line_Item__c.all
  end
  
  # GET a single product
  def show
    @product = Order_Line_Item__c.find(params[:id])
  end
  
end