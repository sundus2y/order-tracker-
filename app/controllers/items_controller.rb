class ItemsController < ApplicationController
  autocomplete :item, :name, :display_value => :to_s, :extra_data => [:item_number], :limit => 20

  before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  # after_action :verify_authorized

  respond_to :html

  def index
    @items = Item.all[1..50]
    respond_with(@items)
    authorize  Item
  end

  def show
    respond_with(@item)
    authorize @item
  end

  def new
    @item = Item.new
    authorize @item
    respond_with(@item)
  end

  def edit
    authorize @item
  end

  def create
    @item = Item.new(item_params)
    flash[:notice] = 'Item was successfully created.' if @item.save
    respond_with(@item,location: items_path)
  end

  def update
    flash[:notice] = 'Item was successfully updated.' if @item.update(item_params)
    respond_with(@item,location: items_path)
  end

  def destroy
    @item.destroy
    respond_with(@item)
  end

  def import
    return redirect_to request.referrer, notice: "Please Select File First" unless params[:file]
    duplicate = Item.import(params[:file])
    redirect_to request.referrer, notice: "All Items Imported Successfully" if duplicate.empty?
    notice += " - Found #{duplicate.count} Duplicate Items" unless duplicate.empty?
    flash[:notice] = notice
    redirect_to request.referrer
  end

  def export

  end

  def template
    respond_to do |format|
      format.xlsx { send_file Item.excel_template}
    end
  end

  private
    def set_item
      @item = Item.find(params[:id])
    end

    def item_params
      params.require(:item).permit(:name, :description, :item_number)
    end

    def get_autocomplete_items(parameters)
      model = parameters[:model]
      limit = parameters[:options][:limit]
      data = parameters[:options][:extra_data]
      data << parameters[:method]
      data << :id
      model.where("LOWER(name) like LOWER(:term) or LOWER(item_number) like LOWER(:term)", term: "%#{parameters[:term]}%").limit(limit)
    end
end
