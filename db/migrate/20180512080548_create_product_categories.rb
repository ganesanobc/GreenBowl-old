class CreateProductCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :product_categories do |t|
      t.belongs_to :product, foreign_key: true, on_delete: :cascade
      t.belongs_to :category, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
