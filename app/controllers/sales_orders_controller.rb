class SalesOrdersController < ApplicationController  
  before_action :set_sales_order, only: [:show, :edit, :update, :destroy, :book, :cancel, :return, :ship]

  before_filter do
    locale = params[:locale]
    Carmen.i18n_backend.locale = locale if locale
  end

  # GET /sales_orders
  # GET /sales_orders.json
  def index    
    if params[:token] || params[:created_date_from] || params[:created_date_to]  \
      || params[:order_date_from] || params[:order_date_to] \
      || params[:total_amount_from] || params[:total_amount_to] || params[:status] \
      || params[:customer_name]
      created_date_from = (params[:created_date_from].blank?) ? Date.parse("01/01/1900",  "%m/%d/%Y") : Date.parse(params[:created_date_from],  "%m/%d/%Y") - 1.day
      created_date_to   = (params[:created_date_to].blank?) ?   Date.parse("01/01/2050",  "%m/%d/%Y") : Date.parse(params[:created_date_to],  "%m/%d/%Y") + 1.day
      order_date_from   = (params[:order_date_from].blank?) ?   Date.parse("01/01/1900",  "%m/%d/%Y") : Date.parse(params[:order_date_from],  "%m/%d/%Y") - 1.day
      order_date_to     = (params[:order_date_to].blank?) ?     Date.parse("01/01/2050",  "%m/%d/%Y") : Date.parse(params[:order_date_to],  "%m/%d/%Y") + 1.day
      @sales_orders = SalesOrder.token_like(params[:token])
                  .by_customer_name(params[:customer_name])
                  .created_at_between(created_date_from, created_date_to)
                  .order_date_between(order_date_from, order_date_to)
                  .total_amount_between(params[:total_amount_from], params[:total_amount_to])
                  .by_status(params[:status])
                  .ordered()
                  .paginate(page: params[:page])      
      @condition = params
    else
      @sales_orders = SalesOrder.ordered.paginate(page: params[:page])
      @condition = params
    end        
  end

  def new
    @sales_order = SalesOrder.new
    @sales_order.token = GlobalMap.sale_number
    @sales_order.sales_items.build    
  end

  def create
    SalesOrder.transaction do
      @sales_order = SalesOrder.new(safe_params)
      @sales_order.status = 'draft'
      @sales_order.order_date = Date.strptime(safe_params[:order_date],  "%Y-%m-%d")
      @sales_order.req_ship_date = Date.strptime(safe_params[:req_ship_date], "%Y-%m-%d")
      @sales_order.estimate_ship_date = Date.strptime(safe_params[:estimate_ship_date], "%Y-%m-%d")

      respond_to do |format|
        if @sales_order.save
          @sales_order.draft!
          result = {:Result => "OK", :Record => @sales_order}
        else
          result = {:Result => "ERROR", :Message =>@sales_order.errors.full_messages}
        end
        format.json {render :json => result}
      end
    end
  end

  # GET /sales_orders/1/edit
  def edit
    @item_data = ''
    @sales_order.sales_items.each do |item|
      @item_data += "['#{item.sold_item.sku}', '#{item.sold_item.name}', #{item.quantity}, #{item.unit_price}, #{item.discount_rate}, #{item.tax_rate}, '', '', #{item.sold_item_id}],"
    end
  end

  # PATCH/PUT /sales_orders/1
  # PATCH/PUT /sales_orders/1.json
  def update
    respond_to do |format|
      @sales_order.sales_items.delete_all
      @sales_order.attributes = safe_params
      @sales_order.order_date = Date.strptime(safe_params[:order_date],  "%Y-%m-%d")
      @sales_order.req_ship_date = Date.strptime(safe_params[:req_ship_date], "%Y-%m-%d")
      @sales_order.estimate_ship_date = Date.strptime(safe_params[:estimate_ship_date], "%Y-%m-%d")
      if @sales_order.update(sales_order_params)
        @sales_order.draft!
        result = {:Result => "OK", :Record => @sales_order}
      else
        result = {:Result => "ERROR", :Message =>@sales_order.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    if @sales_order.draft?
      @sales_order.sales_items.delete_all
      @sales_order.destroy
      respond_to do |format|
        format.html { redirect_to sales_orders_url, notice: 'Sales Order was deleted successfully.' }
        format.json { head :no_content }
      end
    else 
      respond_to do |format|
        format.html { redirect_to sales_orders_url, notice: 'Only Draft Sales Order is able to delete.' }
        format.json { head :no_content }
      end
    end
  end

  def book
    @sales_order.confirm!(current_user)
    respond_to do |format|
      format.html { redirect_to sales_orders_url, notice: 'Sales Order was booked successfully.' }
      format.json { head :no_content }
    end
  end

  # GET /sales_orders/1
  # GET /sales_orders/1.json
  def show
#    if @sales_order.draft?
#      redirect_to edit_sales_order_path(@sales_order)
#    end    
    @sales_orders = SalesOrder.all
  end

  def cancel
    params[:cancel_attributes].each do |elem|
      sales_item = SalesItem.find(elem[1][:id].to_i);
      sales_item.cancel!(elem[1][:quantity], elem[1][:note], current_user)
    end
    @sales_order.cancel!(current_user)
    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def return
    params[:return_attributes].each do |elem|
      sales_item = SalesItem.find(elem[1][:id].to_i);
      sales_item.return!(elem[1][:quantity], elem[1][:note], current_user)
    end
    @sales_order.return!(current_user)
    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def ship
    params[:ship_attributes].each do |elem|
      sales_item = SalesItem.find(elem[1][:id].to_i);
      sales_item.ship!(elem[1][:quantity], elem[1][:note], current_user)
    end
    @sales_order.ship!(current_user)
    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def list_by_type
    case params[:type]
    when 'all'
      @sales_orders = SalesOrder.all
                  .paginate(page: params[:page])
    else
      @sales_orders = SalesOrder.all
    end

    respond_to do |format|
      format.html { render "list" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_order
      @sales_order = nil #SalesOrder.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sales_order_params
      params.require(:sales_order).permit(:token, :status, :notes, :total_amount, :order_at)
    end

    def safe_params
      params[:sales_order].permit(
        :token,
        :order_date,
        :req_ship_date,
        :estimate_ship_date,
        :payment_term,
        :total_amount,        
        :customer_id,
        :notes,        
        sales_items_attributes: [:sold_item_id, :quantity, :unit_price, :discount_rate, :tax_rate]
      )
    end
end
