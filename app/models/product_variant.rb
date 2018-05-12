class ProductVariant < ApplicationRecord
  # relationships
  belongs_to :product

  # validations
  validates :title, presence: true, :uniqueness => {scope: :product_id}
  validates :available, presence: true, inclusion: {in: 0..1}
  validates :add_on_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
