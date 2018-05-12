class CreateOrderItems < ActiveRecord::Migration[5.2]
  def change
    create_table :order_items do |t|
      t.integer :quantity
      t.integer :state
      t.belongs_to :kitchen, foreign_key: true, on_delete: true

      t.timestamps
    end
  end
end
