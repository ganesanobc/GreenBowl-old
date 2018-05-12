class AddKitchenIdToProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :products, :kitchen, foreign_key: true, on_delete: true
  end
end
