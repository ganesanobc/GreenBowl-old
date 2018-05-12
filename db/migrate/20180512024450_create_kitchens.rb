class CreateKitchens < ActiveRecord::Migration[5.2]
  def change
    create_table :kitchens do |t|
      t.string :name
      t.text :description
      t.belongs_to :restaurant, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
