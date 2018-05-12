class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :title
      t.belongs_to :restaurant, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
