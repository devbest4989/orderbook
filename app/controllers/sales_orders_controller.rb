class SalesOrdersController < ApplicationController  
  before_action :set_sales_order, only: [:show, :edit, :update, :destroy, :book, :cancel, :return, :ship, :pack, :remove_activity, :invoice]

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
        @sales_order.status = 'confirmed'
      end
      @sales_order.order_date = Date.strptime(safe_params[:order_date],  "%Y-%m-%d")
      @sales_order.estimate_ship_date = Date.strptime(safe_params[:estimate_ship_date], "%Y-%m-%d")

      respond_to do |format|
        if @sales_order.save
          if params[:save_action] == 'save'
            @sales_order.quote!
            add_action_history('quote', 'create', @sales_order.token)
          else
            @sales_order.confirm!
            add_action_history('confirm', 'create', @sales_order.token)
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
    
    get_first_invoice

    # Self Company Profile
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end        
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
          add_action_history('quote', 'update', @sales_order.token)
        else
          @sales_order.confirm!
          add_action_history('confirm', 'update', @sales_order.token)
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
    add_action_history('confirm', 'update', @sales_order.token)
    respond_to do |format|
      format.html { redirect_to sales_orders_url, notice: 'Sales Order was booked successfully.' }
      format.json { head :no_content }
    end
  end

  # GET /sales_orders/1
  # GET /sales_orders/1.json
  def show
    get_sub_sales_orders
    get_first_invoice

    # Self Company Profile
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end    
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

  def get_invoice
    invoice_activity = SalesItemActivity.where(token: params[:activity]).first;
    ship_activities = SalesItemActivity.where(token: invoice_activity.activity_data);

    respond_to do |format|
      invoice_activity.created_at = invoice_activity.created_at.to_date
      sale_items = []

      ship_activities.each do |elem|
        sale_items << { 
                        name: elem.sales_item.sold_item.name, 
                        quantity: elem.quantity, 
                        price: "$ #{elem.sales_item.unit_price}", 
                        discount: elem.sales_item.discount_rate,
                        tax: elem.sales_item.tax_rate,
                        sub_total: elem.sub_total
                      }
      end      

      result = {:Result => "OK", :invoice => invoice_activity, items: sale_items }
      format.json {render :json => result}
    end    
  end

  def invoice
    invoice_number = GlobalMap.invoice_number
    activity_totals = SalesItemActivity.select("SUM(sub_total) AS sum_sub, SUM(tax) AS sum_tax, SUM(discount) AS sum_discount").where(token: params[:ship_token])

    invoice_activity = SalesItemActivity.new
    invoice_activity.quantity = 0
    invoice_activity.activity = 'invoice'
    invoice_activity.sales_item_id = nil
    invoice_activity.updated_by = current_user
    invoice_activity.token = invoice_number
    invoice_activity.activity_data = params[:ship_token]
    invoice_activity.note = ''
    invoice_activity.sub_total  = activity_totals[0]['sum_sub'].to_f
    invoice_activity.discount   = activity_totals[0]['sum_discount'].to_f
    invoice_activity.tax        = activity_totals[0]['sum_tax'].to_f
    invoice_activity.total      = activity_totals[0]['sum_sub'].to_f + activity_totals[0]['sum_tax'].to_f
    invoice_activity.sales_order_id = params[:id]
    invoice_activity.save

    @sales_order.invoice!(current_user)

    add_action_history('invoice', 'create', invoice_number)

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
      ship_activity.sub_total = elem.sub_total_amount
      ship_activity.discount = elem.discount_amount
      ship_activity.tax = elem.tax_amount
      ship_activity.sales_order_id = params[:id]

      ship_activity.save
    end

    add_action_history('shippment', 'create', shipping_number)

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

    add_action_history('packaging', 'create', track_number)

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
      add_action_history('packaging', 'delete', params[:activity])
      @sales_order.pack!(current_user)
    when 'ship'
      add_action_history('shippment', 'delete', params[:activity])
      @sales_order.ship!(current_user)
    when 'invoice'
      add_action_history('invoice', 'delete', params[:activity])
      @sales_order.invoice!(current_user)
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
    def add_action_history(action_name, action_type, action_number)
      @sales_order.action_histories.create!(action_name: action_name, 
                                            action_type: action_type, 
                                            action_number: action_number, 
                                            user: current_user)
    end

    def set_sales_order
      @sales_order = SalesOrder.find(params[:id])
    end

    def get_first_invoice
      @sales_order_invoice = @sales_order.sales_item_activities.where(activity: 'invoice').first
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
