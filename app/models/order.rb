class Order < ApplicationRecord
  # relationships
  belongs_to :customer
  has_many :order_items

  # validations
  enum status: [:open, :closed]

  # helpers
  def total
    total = 0
    self.order_items.each do |item|
      sub_total = 0
      if item.accepted? || item.paid?
        sub_total += item.selected_product.price
        # item.product_variants.each do |variant|
        #   total += variant.add_on_price
        # end
        total += sub_total * item.quantity
      end
    end
    total
  end

end
