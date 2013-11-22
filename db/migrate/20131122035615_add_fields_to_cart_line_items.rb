class AddFieldsToCartLineItems < ActiveRecord::Migration
  def change
    add_column :cart_line_items, :sfid, :string
    add_column :cart_line_items, :name, :string
    add_column :cart_line_items, :quantity, :integer, default: 1
    add_column :cart_line_items, :price, :decimal
  end
end
