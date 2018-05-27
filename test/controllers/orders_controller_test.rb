require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def visit_restaurant(restaurant)
    get restaurant_path(restaurants(restaurant))
    follow_redirect!
    Order.last
  end

  def post_new_order_item(product)
    post order_items_path, params: {
      quantity: 1,
      state: "accepted",
      kitchen_id:product.kitchen_id,
      product_id:product.id,
      order_id:@target_order.id
    }
  end

  setup do
    # sign in as a customer
    sign_in customers(:one)

    # customer visits the restaurant's page and a new order is created for the customer
    @target_order = visit_restaurant(:one)

    # create sample products
    @product_available = products(:one)
    @product_unavailable = products(:two)
  end

  #############################################################################
  # Test setup

  # test if we are at the orders page
  test 'should be at the orders page' do
    # ensure that the customer is shown the order page
    assert_redirected_to order_path(@target_order)
  end

  #############################################################################
  # Creation of Orders

  test 'should not get a new order when customer revisits the same restaurant' do
    # customer visits the same restaurant
    assert_no_difference('Order.count') do
      visit_restaurant(:one)
    end

    # should be redirected to the same order page
    assert_redirected_to order_path(@target_order)
  end

  test 'should get a new order when customer switches to another restaurant' do
    # customer visits another restaurant, there should be no change in the number of orders
    # since the old order should be destroyed
    assert_no_difference('Order.count') do
      visit_restaurant(:two)
    end

    # should be redirected to the new order page
    assert_not_equal @target_order, Order.last
    assert_redirected_to order_path(Order.last)
  end

  test 'the old order should be deleted if still open when customer switches to another restaurant' do
    # there should not be any change in the number of orders
    assert_no_difference('Order.count') do
      # customer visits another restaurant
      visit_restaurant(:two)
    end
  end

  # test 'should get a new order if I am revisiting the restaurant page after some time' do
  #   # simulate session expiry
  #   session[:order_expires_at] = Time.current - 20.minutes
  #
  #   # customer visits the same restaurant
  #   order = visit_restaurant(:one)
  #
  #   # should be redirected to the same order page
  #   assert_not_equal @target_order.id, order.id
  # end

  #############################################################################
  # Destroy Order

  test 'should get a new order when the current order is deleted' do
    # when the old order is destroyed, a new one should be automatically created
    assert_difference('Order.count', -1) do
      delete order_path(@target_order)
    end

    # to the new order page
    follow_redirect!

    # should be redirected to the new order page
    assert_not_equal @target_order, Order.last
    assert_redirected_to order_path(Order.last)
  end

  #############################################################################
  # Manage order items

  test 'should be able to create a valid order item and add to order if order is open' do
    # create the order item for the order
    post_new_order_item(@product_available)
    assert_equal 1, @target_order.order_items.count
  end

  test 'should not be able to add to order if order is not open' do
    # check if order is open
    @target_order.closed!

    # create the order item for the order
    post_new_order_item(@product_available)
    assert_equal 0, @target_order.order_items.count
  end

  test 'should not be able to add unavialable products to order even if order is open' do
    # create the order item for the order
    assert_raises(ActiveRecord::RecordInvalid) do
      post_new_order_item(@product_unavailable)
    end
  end

  #############################################################################

  # test "should get index" do
  #   get orders_url
  #   assert_response :success
  # end
  #
  # test "should get new" do
  #   get new_order_url
  #   assert_response :success
  # end
  #
  # test "should create order" do
  #   assert_difference('Order.count') do
  #     post orders_url, params: { order: { customer_id: @order.customer_id } }
  #   end
  #
  #   assert_redirected_to order_url(Order.last)
  # end
  #
  # test "should show order" do
  #   get order_url(@order)
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get edit_order_url(@order)
  #   assert_response :success
  # end
  #
  # test "should update order" do
  #   patch order_url(@order), params: { order: { customer_id: @order.customer_id } }
  #   assert_redirected_to order_url(@order)
  # end
  #
  # test "should destroy order" do
  #   assert_difference('Order.count', -1) do
  #     delete order_url(@order)
  #   end
  #
  #   assert_redirected_to orders_url
  # end
end
