class Cart < ActiveRecord::Base
  has_many :cart_line_items, dependent: :destroy
  
  def total_price
    cart_line_items.to_a.sum { |item| item.total_price}
  end
  
end
