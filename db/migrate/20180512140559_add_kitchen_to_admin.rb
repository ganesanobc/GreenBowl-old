class AddKitchenToAdmin < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :kitchen_id, :integer
  end
end
