class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :send_to_kitchen, :pay]

  # GET /orders
  # GET /orders.json
  def index
    # should show all past and present orders
    orders = current_customer.orders.where("created_at > ?", Time.current - 2.days ).order(created_at: :desc)
    unless orders.nil?
      @orders = orders.map do |order|
        order.destroy! if is_dropped_order?(order)
        order.archived! if can_archive_order?(order)
        order
      end
      @can_create_new_order = session.has_key?(:restaurant)
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    # check for valid restaurant
    restaurant_id = session[:restaurant]
    redirect_to orders_path if restaurant_id.nil?

    # load the restaurant and associated products
    restaurant = Restaurant.find(restaurant_id)
    @restaurant_name = restaurant.brand_name
    @categories = restaurant.categories

    # show the current order items
    @order_items = @order.order_items

    # archive current order if already fulfilled
    @order.archived! if @order.closed? && can_archive_order?(@order)

    # restart the session timer
    restart_order_session(@order)
  end

  # POST /orders
  # POST /orders.json
  def new
    # get current customer
    customer = current_customer

    # create new order from session or get the last order
    unless customer.orders.nil?
      begin
        order = customer.orders.find(session[:order]) if session.has_key?(:order)
      rescue => e
        order = customer.orders.last
      end
    end

    # validate the order from session
    order = validate_order(order)

    # create a new order if still empty
    order = customer.orders.open.create!() if order.nil?

    # restart the session timer
    restart_order_session(order)

    # show the order
    redirect_to order_path(order)
  end

  # GET /orders/1/edit
  def edit
    # to allow customer to remove products or adjust the quantity
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    session.delete(:order)
    respond_to do |format|
      format.html { redirect_to new_order_path, notice: 'New order created.' }
      format.json { head :no_content }
    end
  end

  # send the current order to the kitchen before payment
  def send_to_kitchen
    # send all the items to kitchen
    @order.order_items.each do |item|
      item.sent_to_kitchen!
    end

    # save the order to session and start the expiry
    restart_order_session(@order)
    redirect_to order_path(@order)
  end

  # start the payment process for the order items that have been accepted by kitchen
  def pay
    total = 0
    @order.order_items.each do |item|
      sub_total = 0
      if item.accepted? || item.paid?
        sub_total += item.selected_product.price
        # item.product_variants.each do |variant|
        #   total += variant.add_on_price
        # end
        total += sub_total * item.quantity
        item.paid!
      end
    end

    #TODO: process payment

    # close the order
    @order.closed!
    redirect_to order_path(@order)
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:customer_id)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_customer.orders.find(params[:id])
    end

    # Check if order session has expired
    def has_order_session_expired?(order)
      !session[:order_expires_at].nil? &&
        session[:order_expires_at] < Time.current
    end

    # Check if the order can be archived by checking all the order items have been fulfilled
    # or if the order is too old to be meaningful
    def can_archive_order?(order)
      can_archive = false
      unless order.nil?
        can_archive = order.closed?
        order.order_items.each { |item| can_archive &= item.prepared? }
        can_archive &= (Time.current > order.updated_at + 2.days)
      end
      can_archive
    end

    # Check if the order can be deleted by checking that the order is open
    # but has no items and not there is a newer order
    def is_dropped_order?(order)
      is_dropped = true
      unless order.nil?
        is_dropped = (order.open?) &&
          (order.order_items.count == 0) &&
          (Time.current > order.updated_at + 15.minutes)
      end
      is_dropped
    end

    # Restart the order session
    def restart_order_session(order)
      session[:order] = order.id
      session[:order_expires_at] = Time.current + 15.minutes
    end

    # Validate that the order for the new action
    def validate_order(order)
      unless order.nil?
        if order.open? && has_order_session_expired?(order)
          # destroy abandoned order
          order.destroy!
          order = nil
        elsif order.closed?
          # archive last order
          order.archived! if can_archive_order?(order)
          order = nil
        elsif order.archived?
          order = nil
        end
      end
      order
    end
end
