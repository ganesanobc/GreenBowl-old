class AddOperatorIdToKitchens < ActiveRecord::Migration[5.2]
  def change
    add_column :kitchens, :operator_id, :integer
  end
end
