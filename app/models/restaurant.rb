class Restaurant < ApplicationRecord
  # relationships
  has_many :kitchens
  has_many :restaurant_managers
  has_many :managers, class_name:"Admin", through: :restaurant_managers
end
