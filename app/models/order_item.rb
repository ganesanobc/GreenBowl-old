class OrderItem < ApplicationRecord
  # relationships
  belongs_to :kitchen
  #has_one :order, class_name: "Order", foreign_key: :order_id
  #has_one :product, class_name: "Product", foreign_key: :product_id

  def selected_product
    self.product_id ? Product.find_by_id(self.product_id) : nil
  end

  def selected_product=(another_product)
    self.product_id = another_product ? another_product.id : nil
  end

  def parent_order
    self.order_id ? Order.find_by_id(self.order_id) : nil
  end

  def parent_order=(another_order)
    self.order_id = another_order ? another_order.id : nil
  end

  # validations
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  enum state: [:in_creation, :sent_to_kitchen, :accepted, :rejected, :paid, :prepared, :archived]
end
