class CreateRestaurants < ActiveRecord::Migration[5.2]
  def change
    create_table :restaurants do |t|
      t.string :brand_name
      t.string :branch_name
      t.text :description

      t.timestamps
    end
  end
end
