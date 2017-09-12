class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [:show, :edit, :update, :destroy, :book, :cancel, :receive, :remove_activity, :invoice, :update_status]

  before_filter do
    locale = params[:locale]
    Carmen.i18n_backend.locale = locale if locale
  end 

  def list_by_type
    order_key = get_order_key
    case params[:type]
    when 'all'
      @purchase_orders = PurchaseOrder.all
                  .includes(:supplier)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'draft'
      @purchase_orders = PurchaseOrder.where(status: 'draft')
                  .includes(:supplier)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'approved'
      @purchase_orders = PurchaseOrder.where(status: 'approved')
                  .includes(:supplier)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'received'
      @purchase_orders = PurchaseOrder.where(status: ['received', 'partial_received'])
                  .includes(:supplier)
                  .order(order_key)
                  .paginate(page: params[:page])
    else
      @purchase_orders = PurchaseOrder.all.includes(:supplier)
                  .order(order_key)
                  .paginate(page: params[:page])

    end

    respond_to do |format|
      format.html { render "list" }
    end
  end

  def new
    @purchase_order = PurchaseOrder.new
    @purchase_order.token = GlobalMap.purchase_number
    @purchase_order.purchase_items.build    
  end

  def create
    PurchaseOrder.transaction do
      @purchase_order = PurchaseOrder.new(safe_params)
      if params[:save_action] == 'draft'
        @purchase_order.status = 'draft'
      else
        @purchase_order.status = 'approved'
      end
      @purchase_order.order_date = Date.strptime(safe_params[:order_date],  "%d-%m-%Y")
      @purchase_order.issue_date = Date.strptime(safe_params[:issue_date], "%d-%m-%Y")

      respond_to do |format|
        if @purchase_order.save
          if params[:save_action] == 'draft'
            @purchase_order.draft!
            add_action_history('draft', 'create', @purchase_order.token)
          else
            @purchase_order.approve!
            add_action_history('approve', 'create', @purchase_order.token)
            make_order_invoice
          end          
          
          result = {:Result => "OK", :Record => @purchase_order}
        else
          result = {:Result => "ERROR", :Message =>@purchase_order.errors.full_messages}
        end
        format.json {render :json => result}
      end
    end
  end

  # GET /purchase_orders/1/edit
  def edit
    @item_data = ''
    @purchase_order.purchase_items.each do |item|
      @item_data += "['#{item.purchased_item.sku}', '#{item.purchased_item.name}', #{item.quantity}, #{item.unit_price}, #{item.discount_rate}, #{item.tax_rate}, '', '', #{item.purchased_item_id}],"
    end
    get_sub_purchase_orders
    
    # Self Company Profile
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end        
  end

  # GET /purchase_orders/1
  # GET /purchase_orders/1.json
  def show
    get_sub_purchase_orders

    # Self Company Profile
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end    
  end

  # DELETE /purchase_orders/1
  # DELETE /purchase_orders/1.json
  def destroy
    if @purchase_order.draft?
      @purchase_order.purchase_items.delete_all
      @purchase_order.destroy
      respond_to do |format|
        format.html { redirect_to list_by_type_purchase_orders_path(type: 'all'), notice: 'Purchase Order was deleted successfully.' }
        format.json { head :no_content }
      end
    else 
      respond_to do |format|
        format.html { redirect_to purchase_orders_url, notice: 'Only Draft Purchase Order is able to delete.' }
        format.json { head :no_content }
      end
    end
  end

  # PATCH/PUT /purchase_orders/1
  # PATCH/PUT /purchase_orders/1.json
  def update
    respond_to do |format|
      unless params[:save_action].blank?
        @purchase_order.attributes = safe_params
        @purchase_order.order_date = Date.strptime(safe_params[:order_date],  "%d-%m-%Y")
        @purchase_order.issue_date = Date.strptime(safe_params[:issue_date], "%d-%m-%Y")
      else
        @purchase_order.purchase_items.delete_all
        @purchase_order.purchase_custom_items.delete_all
      end

      if @purchase_order.update(safe_params)
        if params[:save_action] == 'draft'
          @purchase_order.draft!
          add_action_history('draft', 'update', @purchase_order.token)
        elsif params[:save_action] == 'approve'
          @purchase_order.approve!
          add_action_history('approve', 'update', @purchase_order.token)
          make_order_invoice
        else
          @purchase_order.draft!
        end        
        # redirect_to purchase_order_url(@purchase_order)
        result = {:Result => "OK", :Record => @purchase_order, :url => purchase_order_url(@purchase_order, {type: 'all'})}
      else
        result = {:Result => "ERROR", :Message =>@purchase_order.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  def update_status
    if params[:save_action] == 'draft'
      @purchase_order.draft!
      add_action_history('draft', 'update', @purchase_order.token)
    else
      @purchase_order.approve!
      add_action_history('approve', 'update', @purchase_order.token)
      make_order_invoice
    end
    redirect_to purchase_order_url(@purchase_order)
  end

  def receive
    receive_number = GlobalMap.receive_number
    params[:receive_attributes].each do |elem|
      purchase_item = PurchaseItem.find(elem[1][:id].to_i);
      purchase_item.receive!(elem[1][:quantity], elem[1][:note], current_user, receive_number)
    end

    add_action_history('receive', 'create', receive_number)

    @purchase_order.confirm_status!(current_user)
    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def remove_activity
    PurchaseItemActivity.where(token: params[:activity]).destroy_all
    case params[:type]
    when 'receive'
      add_action_history('receive', 'delete', params[:activity])
      @purchase_order.receive!(current_user)
    when 'invoice'
      add_action_history('invoice', 'delete', params[:activity])
      @purchase_order.invoice!(current_user)
    end

    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  def invoice
    invoice_number = GlobalMap.invoice_number

    invoice = Invoice.new
    invoice.token = invoice_number
    invoice.purchase_order_id = params[:id]
    invoice.sub_total = params[:sub_total]
    invoice.discount = params[:discount_total]
    invoice.tax = params[:tax_total]
    invoice.total = params[:total]
    invoice.paid = params[:paid].to_f == 0 ? 0 : params[:paid]
    invoice.status = (invoice.paid == 0) ? 0 : 1
    invoice.preview_token = SecureRandom.hex(15)
    invoice.save

    params[:invoice_attributes].each do |elem|
      invoice_item = InvoiceItem.new
      invoice_item.invoice_id = invoice.id
      invoice_item.purchase_item_id = (elem[1][:type] == 'product') ? elem[1][:id].to_i : 0
      invoice_item.quantity   = elem[1][:quantity].to_i
      invoice_item.discount   = elem[1][:discount]
      invoice_item.tax        = elem[1][:tax]
      invoice_item.sub_total  = elem[1][:sub_total]
      invoice_item.purchase_custom_item_id = (elem[1][:type] != 'product') ? elem[1][:id].to_i : 0
      invoice_item.save
    end

    add_action_history('invoice', 'create', invoice_number)
    @purchase_order.invoice!(current_user)

    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def add_action_history(action_name, action_type, action_number)
      @purchase_order.action_histories.create!(action_name: action_name, 
                                            action_type: action_type, 
                                            action_number: action_number, 
                                            user: current_user)
    end

    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end  

    def get_order_key
      case params[:order]
      when 'date'
        "purchase_orders.order_date #{params[:sort]}"
      when 'order_no'
        "purchase_orders.token #{params[:sort]}"
      when 'company'
        "suppliers.company_name #{params[:sort]}, suppliers.first_name #{params[:sort]}"
      when 'amount'
        "purchase_orders.total_amount #{params[:sort]}"
      when 'status'
        "purchase_orders.status #{params[:sort]}"
      else
        "purchase_orders.created_at #{params[:sort]}"
      end      
    end

    def get_sub_purchase_orders
      case params[:type]
      when 'all'
        @purchase_orders = PurchaseOrder.includes(:supplier).all.ordered
      when 'draft'
        @purchase_orders = PurchaseOrder.includes(:supplier).draft.ordered
      when 'approved'
        @purchase_orders = PurchaseOrder.includes(:supplier).approved.ordered
      when 'received'
        @purchase_orders = PurchaseOrder.includes(:supplier).received.ordered
      else
        @purchase_orders = PurchaseOrder.includes(:supplier).all.ordered
      end
    end    

    # Never trust parameters from the scary internet, only allow the white list through.
    def purchase_order_params
      params.require(:purchase_order).permit(:token, :status, :notes, :total_amount, :order_at)
    end

    def safe_params
      params[:purchase_order].permit(
        :token,
        :booked_by_id,
        :order_date,
        :issue_date,
        :payment_term_id,
        :condition_term_id,
        :warehouse_id,
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
        :supplier_id,
        :notes,        
        purchase_items_attributes: [:purchased_item_id, :quantity, :unit_price, :discount_rate, :tax_rate],
        purchase_custom_items_attributes: [:item_name, :quantity, :unit_price, :discount_rate, :tax_rate]
      )
    end

    def make_order_invoice
      if @purchase_order.invoices.length > 0
        return
      end

      invoice_number = GlobalMap.invoice_number

      invoice                 = Invoice.new
      invoice.token           = invoice_number
      invoice.purchase_order_id  = @purchase_order.id
      invoice.sub_total       = @purchase_order.sub_total
      invoice.discount        = @purchase_order.discount_amount 
      invoice.tax             = @purchase_order.tax_amount
      invoice.shipping        = 0
      invoice.total           = @purchase_order.total_amount
      invoice.preview_token   = SecureRandom.hex(15)
      invoice.paid            = 0
      invoice.status          = 0
      invoice.save

      @purchase_order.purchase_items.each do |elem|
        invoice_item                = InvoiceItem.new
        invoice_item.invoice_id     = invoice.id
        invoice_item.purchase_item_id  = elem.id
        invoice_item.quantity       = elem.quantity
        invoice_item.discount       = elem.discount_rate
        invoice_item.tax            = elem.tax_rate
        invoice_item.sub_total      = elem.quantity * elem.unit_price - elem.discount_amount
        invoice_item.purchase_custom_item_id = 0
        invoice_item.save
      end

      @purchase_order.purchase_custom_items.each do |elem|
        invoice_item                = InvoiceItem.new
        invoice_item.invoice_id     = invoice.id
        invoice_item.purchase_item_id  = 0
        invoice_item.quantity       = elem.quantity
        invoice_item.discount       = elem.discount_rate
        invoice_item.tax            = elem.tax_rate
        invoice_item.sub_total      = elem.quantity * elem.unit_price - elem.discount_amount
        invoice_item.purchase_custom_item_id = elem.id
        invoice_item.save
      end

      add_action_history('invoice', 'create', invoice_number)      
    end
end