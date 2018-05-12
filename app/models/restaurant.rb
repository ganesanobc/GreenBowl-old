class Restaurant < ApplicationRecord
  # relationships
  has_many :kitchens
  has_many :restaurant_managers
  has_many :managers, class_name:"Admin", through: :restaurant_managers

  # validations
  validates :brand_name, presence: true, uniqueness: true
end
