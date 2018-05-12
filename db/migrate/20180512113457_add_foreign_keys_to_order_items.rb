class AddForeignKeysToOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :order_items, :order_id, :integer
    add_column :order_items, :product_id, :integer
  end
end
