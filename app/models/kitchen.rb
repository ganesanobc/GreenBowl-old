class Kitchen < ApplicationRecord
  # relationships
  belongs_to :restaurant
  has_one :kitchen_operator, class_name: "Admin"
end
