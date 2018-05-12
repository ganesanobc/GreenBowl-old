class CreateProductVariants < ActiveRecord::Migration[5.2]
  def change
    create_table :product_variants do |t|
      t.string :title
      t.text :description
      t.decimal :add_on_price
      t.integer :available
      t.belongs_to :product, foreign_key: true, on_delete: :cascade

      t.timestamps
    end
  end
end
