class KitchensController < ApplicationController
  # before_action :authenticate_admin!

  # while manager can manage all the kitchens under him ...
  # before_action :can_manage_kitchens?, only: [:index, :new, :create, :destroy]

  # ... the kitchen operator should be allowed to manage his own kitchen except to delete it
  before_action :set_kitchen, only: [:show, :edit, :update, :destroy]
  # before_action :can_manage_current_kitchen?, only: [:show, :edit, :update]

  # GET /kitchens
  # GET /kitchens.json
  def index
    @kitchens = Kitchen.all
  end

  # GET /kitchens/1
  # GET /kitchens/1.json
  def show
  end

  # GET /kitchens/new
  def new
    @kitchen = Kitchen.new
  end

  # GET /kitchens/1/edit
  def edit
  end

  # POST /kitchens
  # POST /kitchens.json
  def create
    @kitchen = Kitchen.new(kitchen_params)

    respond_to do |format|
      if @kitchen.save
        format.html { redirect_to @kitchen, notice: 'Kitchen was successfully created.' }
        format.json { render :show, status: :created, location: @kitchen }
      else
        format.html { render :new }
        format.json { render json: @kitchen.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitchens/1
  # PATCH/PUT /kitchens/1.json
  def update
    respond_to do |format|
      if @kitchen.update(kitchen_params)
        format.html { redirect_to @kitchen, notice: 'Kitchen was successfully updated.' }
        format.json { render :show, status: :ok, location: @kitchen }
      else
        format.html { render :edit }
        format.json { render json: @kitchen.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitchens/1
  # DELETE /kitchens/1.json
  def destroy
    @kitchen.destroy
    respond_to do |format|
      format.html { redirect_to kitchens_url, notice: 'Kitchen was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kitchen
      @kitchen = Kitchen.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def kitchen_params
      params.require(:kitchen).permit(:name, :description, :restaurant_id)
    end

    # check if allowed to manage kitchens
    def can_manage_kitchens?
      current_admin.manager?
    end

    # check if allowed to manage the current kitchens
    def can_manage_current_kitchen?
      current_admin.manager? ||
      (current_admin.operator? && current_admin.kitchen == @kitchen)
    end

end
