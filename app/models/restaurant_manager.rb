class RestaurantManager < ApplicationRecord
  belongs_to :restaurant
  belongs_to :manager, class_name: "Admin"
end
