class Order < ApplicationRecord
  # relationships
  belongs_to :customer
  has_many :order_items

  # validations
  enum status: [:open, :closed]
end
