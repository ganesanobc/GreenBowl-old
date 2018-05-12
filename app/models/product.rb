class Product < ApplicationRecord
  # relationships
  belongs_to :kitchen
  
  has_many :product_variants
  has_many :product_categories
  has_many :categories, through: :product_categories

  # validations
  validates :title, presence: true, :uniqueness => {scope: :kitchen_id}
  validates :available, presence: true, inclusion: {in: 0..1}
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
