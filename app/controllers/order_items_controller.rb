class OrderItemsController < ApplicationController
  before_action :set_order_item, only: [:show, :edit, :update, :destroy, :accept, :reject, :prepared]

  # GET /order_items
  # GET /order_items.json
  def index
    # @order_items = current_admin.order_items
  end

  # GET /order_items/1
  # GET /order_items/1.json
  def show
  end

  # GET /order_items/new
  def new
    @order_item = OrderItem.new
  end

  # GET /order_items/1/edit
  def edit
  end

  # POST /order_items
  # POST /order_items.json
  def create
    order = Order.find(order_item_params[:order_id])
    kitchen = Kitchen.find(order_item_params[:kitchen_id])

    @order_item = kitchen.order_items.in_creation.build(order_item_params)
    @order_item.selected_product_id = order_item_params[:product_id]
    @order_item.save!

    restart_order_session(order)
    redirect_to order_path(order)

    # respond_to do |format|
    #   if @order_item.save
    #     format.html { redirect_to @order_item, notice: 'Order item was successfully created.' }
    #     format.json { render :show, status: :created, location: @order_item }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @order_item.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /order_items/1
  # PATCH/PUT /order_items/1.json
  def update
    respond_to do |format|
      if @order_item.update(order_item_params)
        format.html { redirect_to @order_item, notice: 'Order item was successfully updated.' }
        format.json { render :show, status: :ok, location: @order_item }
      else
        format.html { render :edit }
        format.json { render json: @order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_items/1
  # DELETE /order_items/1.json
  def destroy
    parent_order = @order_item.parent_order
    @order_item.destroy
    redirect_to order_path(parent_order)

    # respond_to do |format|
    #   format.html { redirect_to order_items_url, notice: 'Order item was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
  end

  def accept
    @order_item.accepted!
    redirect_to kitchen_path(@order_item.kitchen)
  end

  def reject
    @order_item.rejected!
    redirect_to kitchen_path(@order_item.kitchen)
  end

  def prepared
    @order_item.prepared!
    redirect_to kitchen_path(@order_item.kitchen)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_item
      @order_item = OrderItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_item_params
      params.permit(:quantity, :state, :kitchen_id, :product_id, :order_id)
      #params.require(:order_item).permit(:quantity, :state, :kitchen_id, :product_id, :order_id)
    end

    def restart_order_session(order)
      session[:order_expires_at] = Time.current + 15.minutes
    end
end
