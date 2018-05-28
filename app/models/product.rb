class Product < ApplicationRecord
  # relationships
  belongs_to :kitchen
  has_one_attached :image

  has_many :product_variants
  has_many :product_categories
  has_many :categories, through: :product_categories

  # validations
  validates :available, presence: true
  enum available: [:available, :not_available]
  validates :title, presence: true, :uniqueness => {scope: :kitchen_id}
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
