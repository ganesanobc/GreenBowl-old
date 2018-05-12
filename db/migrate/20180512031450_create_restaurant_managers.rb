class CreateRestaurantManagers < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurant_managers do |t|
      t.belongs_to :restaurant, foreign_key: true, on_delete: :cascade
      t.belongs_to :manager, foreign_key: { to_table: :admins }, on_delete: :cascade
      t.timestamps
    end
  end
end
