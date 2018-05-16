class OrdersController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_order, only: [:show, :edit, :update, :destroy, :send_to_kitchen, :pay]

  # GET /orders
  # GET /orders.json
  def index
    # should show all past and present orders
    @orders = current_customer.orders
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    # show the current order items
    @order_items = @order.order_items

    # show the menu at the bottom of page
    restaurant = Restaurant.find(session[:restaurant])
    if !restaurant.nil?
      @restaurant_name = restaurant.brand_name
      @products = restaurant.products
    end
  end

  # POST /orders
  # POST /orders.json
  def new
    # check if there is an existing order that was accessed in the last 15 mins
    # but is still open
    # else create a new order for the current customer
    @order = last_valid_open_order

    # save the order to session and start the expiry
    restart_order_session(@order)
    redirect_to order_path(@order)

    # respond_to do |format|
    #   if @order.save
    #     format.html { redirect_to @order, notice: 'Order was successfully created.' }
    #     format.json { render :show, status: :created, location: @order }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @order.errors, status: :unprocessable_entity }
    #   end
    # end
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
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
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
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = current_customer.orders.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:customer_id)
    end

    def has_order_session_expired
      !session[:order_expires_at].nil? && session[:order_expires_at] < Time.current
    end

    def restart_order_session(order)
      session[:order] = order.id
      session[:order_expires_at] = Time.current + 15.minutes
    end

    # Get the last open order created by the customer in the last 30 mins
    def last_valid_open_order
      order = Order.find(session[:order]) unless session[:order].nil?
      if !order.nil?
        order.destroy if order.open? && has_order_session_expired
        order = nil
      end
      order = current_customer.orders.create!() if order.nil?
    end
end
