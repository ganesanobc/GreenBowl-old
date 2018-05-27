class OrderItem < ApplicationRecord
  # relationships
  belongs_to :kitchen

  def selected_product
    if @_selected_product.nil?
      @_selected_product = self.product_id ? Product.find_by_id(self.product_id) : nil
    end
    @_selected_product
  end

  def selected_product=(another_product)
    self.product_id = another_product ? another_product.id : nil
    @_selected_product = another_product
  end

  def selected_product_id=(another_product_id)
    self.product_id = another_product_id
    @_selected_product = nil
    selected_product
  end

  def parent_order
    if @_parent_order.nil?
      @_parent_order = self.order_id ? Order.find_by_id(self.order_id) : nil
    end
    @_parent_order
  end

  def parent_order=(another_order)
    self.order_id = another_order ? another_order.id : nil
    @_parent_order = another_order
  end

  def selected_product_is_available
    errors.add(:product_id, "is NOT available") unless selected_product.available?
  end

  # validations
  validate :selected_product_is_available
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  enum state: [:in_creation, :sent_to_kitchen, :accepted, :rejected, :paid, :prepared, :archived]
end
