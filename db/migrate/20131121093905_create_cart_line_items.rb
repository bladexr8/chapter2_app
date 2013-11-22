class CreateCartLineItems < ActiveRecord::Migration
  def change
    create_table :cart_line_items do |t|
      t.belongs_to :cart, index: true
      t.timestamps
    end
  end
end
