class Category < ApplicationRecord
  # relationships
  belongs_to :restaurant
  
  has_many :product_categories
  has_many :products, through: :product_categories

  # validations
  validates :title, presence: true, :uniqueness => {scope: :restaurant_id}
end
