class SalesOrdersController < ApplicationController  
  before_action :set_sales_order, only: [:show, :edit, :update, :destroy, :book, :cancel, :return, :ship, :pack, :remove_activity]

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
      if params[:save_action] == 'save'
        @sales_order.status = 'quote'
      else
        @sales_order.status = 'confirm'
      end
      @sales_order.order_date = Date.strptime(safe_params[:order_date],  "%Y-%m-%d")
      @sales_order.estimate_ship_date = Date.strptime(safe_params[:estimate_ship_date], "%Y-%m-%d")

      respond_to do |format|
        if @sales_order.save
          if params[:save_action] == 'save'
            @sales_order.quote!
          else
            @sales_order.confirm!
          end
          
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
    get_sub_sales_orders
  end

  # PATCH/PUT /sales_orders/1
  # PATCH/PUT /sales_orders/1.json
  def update
    respond_to do |format|
      @sales_order.attributes = safe_params
      @sales_order.order_date = Date.strptime(safe_params[:order_date],  "%Y-%m-%d")
      @sales_order.estimate_ship_date = Date.strptime(safe_params[:estimate_ship_date], "%Y-%m-%d")
      if @sales_order.update(safe_params)
        if params[:save_action] == 'quote'
          @sales_order.quote!
        else
          @sales_order.confirm!
        end

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
    if @sales_order.quote?
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
    get_sub_sales_orders
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
    sales_item_activities = SalesItemActivity.where("sales_item_activities.token IN (#{params[:pack_tokens]})")
    shipping_number = GlobalMap.shipping_number
    sales_item_activities.each do |elem|      
      ship_activity = SalesItemActivity.new
      ship_activity.quantity = elem.quantity.to_i
      ship_activity.activity = 'ship'
      ship_activity.sales_item_id = elem.sales_item_id.to_i
      ship_activity.updated_by = current_user
      ship_activity.token = shipping_number
      ship_activity.activity_data = elem.token
      ship_activity.note = ''
      ship_activity.save
    end
    @sales_order.ship!(current_user)
    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def pack
    track_number = GlobalMap.track_number
    params[:pack_attributes].each do |elem|
      sales_item = SalesItem.find(elem[1][:id].to_i);
      sales_item.pack!(elem[1][:quantity], elem[1][:note], current_user, track_number)
    end
    @sales_order.pack!(current_user)
    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def remove_activity
    SalesItemActivity.where(token: params[:activity]).destroy_all
    case params[:type]
    when 'pack'
      @sales_order.pack!(current_user)
    when 'ship'
      @sales_order.ship!(current_user)
    end

    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def list_by_type
    order_key = get_order_key
    case params[:type]
    when 'all'
      @sales_orders = SalesOrder.all
                  .includes(:customer)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'quote'
      @sales_orders = SalesOrder.where(status: 'quote')
                  .includes(:customer)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'confirmed'
      @sales_orders = SalesOrder.where(status: 'confirmed')
                  .includes(:customer)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'shipped'
      @sales_orders = SalesOrder.where(status: 'shipped')
                  .includes(:customer)
                  .order(order_key)
                  .paginate(page: params[:page])
    else
      @sales_orders = SalesOrder.all.includes(:customer)
                  .order(order_key)
                  .paginate(page: params[:page])

    end

    respond_to do |format|
      format.html { render "list" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_order
      @sales_order = SalesOrder.find(params[:id])
    end

    def get_sub_sales_orders
      case params[:type]
      when 'all'
        @sales_orders = SalesOrder.includes(:customer).all.ordered
      when 'quote'
        @sales_orders = SalesOrder.includes(:customer).quote.ordered
      when 'confirmed'
        @sales_orders = SalesOrder.includes(:customer).confirmed.ordered
      when 'shipped'
        @sales_orders = SalesOrder.includes(:customer).shipped.ordered
      when 'drop_shipped'
        @sales_orders = SalesOrder.includes(:customer).drop_shipped.ordered
      when 'invoice'
        @sales_orders = SalesOrder.includes(:customer).invoice.ordered
      else
        @sales_orders = SalesOrder.includes(:customer).all.ordered
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sales_order_params
      params.require(:sales_order).permit(:token, :status, :notes, :total_amount, :order_at)
    end

    def safe_params
      params[:sales_order].permit(
        :token,
        :booked_by_id,
        :order_date,
        :estimate_ship_date,
        :shipping_method_id,
        :price_name,
        :contact_name,
        :contact_phone,
        :contact_email,        
        :payment_term,
        :ref_no,
        :bill_street,
        :bill_suburb,
        :bill_city,
        :bill_state,
        :bill_postcode,
        :bill_country,
        :ship_street,
        :ship_suburb,
        :ship_city,
        :ship_state,
        :ship_postcode,
        :ship_country,        
        :total_amount,        
        :customer_id,
        :notes,        
        sales_items_attributes: [:sold_item_id, :quantity, :unit_price, :discount_rate, :tax_rate]
      )
    end

    def get_order_key
      case params[:order]
      when 'date'
        "sales_orders.order_date #{params[:sort]}"
      when 'order_no'
        "sales_orders.token #{params[:sort]}"
      when 'company'
        "customers.company_name #{params[:sort]}, customers.first_name #{params[:sort]}"
      when 'amount'
        "sales_orders.total_amount #{params[:sort]}"
      when 'status'
        "sales_orders.status #{params[:sort]}"
      else
        "sales_orders.created_at #{params[:sort]}"
      end      
    end    
end
