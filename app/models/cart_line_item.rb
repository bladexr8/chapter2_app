class CartLineItem < ActiveRecord::Base
  belongs_to :cart
  
  def total_price
    price * quantity
  end
  
end
