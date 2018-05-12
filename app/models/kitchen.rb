class Kitchen < ApplicationRecord
  # relationships
  belongs_to :restaurant

  has_many :products
  has_many :order_items

  def operator
    if self.operator_id
      sql = "SELECT admins.* FROM admins WHERE admins.id = #{self.operator_id} LIMIT 1"
      Admin.find_by_sql(sql).first
    else
      nil
    end
  end

  def operator=(another_operator)
    self.operator_id = another_operator ? another_operator.id : nil
  end

  # validations
  ## ensure that the kitchen name is not duplicated within the restaurant
  validates :name, presence: true, :uniqueness => {scope: :restaurant_id}
end
