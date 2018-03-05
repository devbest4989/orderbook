class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :cancel, :invoice_detail_info, :credit_note]

  # GET /invoices
  # GET /invoices.json
  def index
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    if params[:type].nil?
      params[:type] = 'all'
    end
    get_sub_invoices
    set_sales_order

    @pending_credit_notes = InvoiceExtraItem.where(is_paid: 0).where.not(invoice_id: @invoice.id).where(customer_id: @invoice.sales_order.customer.id).sum(:total)

    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end    
  end

  # GET /invoices/new
  def new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  # POST /invoices.json
  def create
  end

  def list_by_type
    order_key = get_order_key
    case params[:type]
    when 'all'
      @invoices = Invoice.where.not(sales_order_id: 0)
                  .joins("LEFT JOIN sales_orders ON invoices.sales_order_id = sales_orders.id LEFT JOIN customers ON sales_orders.customer_id = customers.id")
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'draft'
      @invoices = Invoice.where.not(sales_order_id: 0).where(status: 0)
                  .joins("LEFT JOIN sales_orders ON invoices.sales_order_id = sales_orders.id LEFT JOIN customers ON sales_orders.customer_id = customers.id")
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'confirmed'
      @invoices = Invoice.where.not(sales_order_id: 0).where(status: 1)
                  .joins("LEFT JOIN sales_orders ON invoices.sales_order_id = sales_orders.id LEFT JOIN customers ON sales_orders.customer_id = customers.id")
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'sent'
      @invoices = Invoice.where.not(sales_order_id: 0).where(status: 2)
                  .joins("LEFT JOIN sales_orders ON invoices.sales_order_id = sales_orders.id LEFT JOIN customers ON sales_orders.customer_id = customers.id")
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'partial'
      @invoices = Invoice.where.not(sales_order_id: 0).where(status: 3)
                  .joins("LEFT JOIN sales_orders ON invoices.sales_order_id = sales_orders.id LEFT JOIN customers ON sales_orders.customer_id = customers.id")
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'paid'
      @invoices = Invoice.where.not(sales_order_id: 0).where(status: 4)
                  .joins("LEFT JOIN sales_orders ON invoices.sales_order_id = sales_orders.id LEFT JOIN customers ON sales_orders.customer_id = customers.id")
                  .order(order_key)
                  .paginate(page: params[:page])
    end

    respond_to do |format|
      format.html { render "list" }
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    invoice = Invoice.find(params[:id])
    invoice.sub_total = params[:sub_total]
    invoice.discount = params[:discount_total]
    invoice.tax = params[:tax_total]
    invoice.shipping = params[:shipping_total]
    invoice.total = params[:total]
    # invoice.paid = params[:action_name] == 'update' ? 0 : params[:total] #params[:paid].to_f == 0 ? 0 : params[:paid]
    # invoice.status = params[:action_name] == 'update' ? 0 : 1
    invoice.file_name = ''
    invoice.save

    invoice.invoice_items.delete_all
    params[:invoice_attributes].each do |elem|
      invoice_item = InvoiceItem.new
      invoice_item.invoice_id = invoice.id
      invoice_item.quantity   = elem[1][:quantity].to_i
      invoice_item.discount   = elem[1][:discount]
      invoice_item.tax        = elem[1][:tax]
      invoice_item.sub_total  = elem[1][:sub_total]
      invoice_item.sales_item_id = (elem[1][:type] == 'product') ? elem[1][:id].to_i : 0
      invoice_item.sales_custom_item_id = (elem[1][:type] != 'product') ? elem[1][:id].to_i : 0
      invoice_item.save
    end

    add_action_history('invoice', 'update', invoice.token)

    invoice.sales_order.invoice!(current_user)

    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice.sales_order.confirm_status!
    @invoice.invoice_items.destroy_all
    @invoice.payments.destroy_all
    @invoice.destroy
    add_action_history('invoice', 'delete', @invoice.token)

    respond_to do |format|
      if request.xhr?
        result = {:Result => "OK" }
        format.json {render :json => result}
      else
        format.html { redirect_to list_by_type_invoices_path(type: 'all')}
      end
    end
  end

  def generate_pdf
    set_invoice
    # Self Company Profile
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end

    if @invoice.file_name.blank? || @invoice.is_updated_pdf
      begin
        filename = SecureRandom.hex(10) + '_' + @invoice.updated_at.to_i.to_s + '.pdf'
      end while Invoice.exists?(:file_name => filename)      

      save_path = Rails.root.join('public/invoices', filename)
      File.open(save_path, 'wb') do |file|
        file << render_to_string(
           :pdf => "invoice",         
           :page_size => "A4",
           :template => 'invoices/generate_pdf.pdf.haml',
           :layout => '/layouts/invoice.pdf.haml',
           :locals => { 'invoice' => @invoice },
           :header =>{
              :html =>{
                :template => 'invoices/header.pdf.haml',
                :locals => { 'invoice' => @invoice },
              },
              :spacing => 0
           },
           :footer =>{
              :html =>{
                :template => 'invoices/footer.pdf.haml',
                :locals => { 'invoice' => @invoice },
              },
              :spacing => 0
           }           
         )
      end
      @invoice.file_name = filename
      @invoice.save
    end

    redirect_path = '/invoices/' + @invoice.file_name
    redirect_to redirect_path

    # respond_to do |format|
    #   format.pdf do
    #     render pdf: "invoice", layout: '/layouts/invoice.pdf.haml'
    #   end
    # end    
  end

  def print
  end

  def mail
  end

  def remove_payment
    payment = Payment.find(params[:payment])
    payment.delete

    invoice = Invoice.find(params[:id])
    invoice.remove_payment!

    redirect_to invoice_path(params[:id], type: params[:type])
  end

  def add_payment
    set_invoice
    payment = Payment.new
    payment.invoice_id = @invoice.id
    payment.payment_date = Date.strptime(params[:payment_date],  "%d-%m-%Y")
    payment.payment_mode = params[:payment_mode]
    payment.reference_no = params[:reference_no]
    payment.note = params[:note]
    payment.amount = params[:payment_amount]
    
    pending_credit_notes = 0
    if params[:is_include_credit_note]
      pending_credit_notes = InvoiceExtraItem.where(is_paid: 0).where.not(invoice_id: @invoice.id).where(customer_id: @invoice.sales_order.customer.id).sum(:total)
  
      extra_items = InvoiceExtraItem.where(is_paid: 0).where.not(invoice_id: @invoice.id).where(customer_id: @invoice.sales_order.customer.id)
      extra_items.each do |item|
        item.is_paid = 1
        item.paid_invoice_id = @invoice.id
        item.paid_invoice_type = @invoice.class
        item.save
      end
    end


    respond_to do |format|
      result = {}
      if params[:payment_amount].to_f == 0 || payment.save
        if params[:type] == 'credit'
          result = {:Result => "OK", 
                    :Paid => @invoice.total_paid, 
                    :Balance => @invoice.total_credit_note, 
                    :Status => @invoice.status_text.upcase, 
                    :StatusClass => @invoice.status_class }
        else
          @invoice.add_payment!
          result = {:Result => "OK", 
                    :Paid => @invoice.total_paid, 
                    :Balance => @invoice.total - @invoice.total_paid, 
                    :Status => @invoice.status_text.upcase, 
                    :StatusClass => @invoice.status_class }
        end
      else
        result = {:Result => "Failed", :Message => payment.errors.full_messages }
      end
      format.json {render :json => result}
    end
  end

  def approve
    set_invoice
    if @invoice.draft? || @invoice.cancelled?
      @invoice.status = 'confirmed'
      @invoice.save
      add_action_history('invoice', 'update', @invoice.token)
    end
    if request.xhr?
      respond_to do |format|
        result = {:Result => "OK" }
        format.json {render :json => result}
      end      
    else    
      redirect_to invoice_path(@invoice, type: params[:type])
    end
  end

  def cancel
    @invoice.status = 'cancelled'
    @invoice.reason = params[:reason]
    @invoice.save

    @invoice.sales_order.invoice!(current_user)
    add_action_history('invoice', 'cancelled', @invoice.token)

    respond_to do |format|
      if request.xhr?
        result = {:Result => "OK" }
        format.json {render :json => result}
      else
        format.html { redirect_to list_by_type_invoice_path(type: 'all'), notice: 'Invoice cancelled successfully.' }
      end
    end
  end

  def invoice_detail_info
    invoice_item = []
    @invoice.invoice_items.each do |item|
      if item.sales_item
        elem = {
          sku: item.sales_item.sold_item.sku,
          name: item.sales_item.sold_item.name,
          quantity: item.available_quantity,
          unit_price: item.sales_item.unit_price,
          discount_rate: item.sales_item.discount_rate,
          tax_rate: item.sales_item.tax_rate,        
          id: item.sales_item.id
        }
        invoice_item << elem
      end
    end

    pending_credit_notes = InvoiceExtraItem.where(is_paid: 0).where.not(invoice_id: @invoice.id).where(customer_id: @invoice.sales_order.customer.id).sum(:total)    

    result = {:result => "OK",
              :customer => @invoice.sales_order.customer.company_title,
              :token => @invoice.token,
              :credit_note_url => credit_note_invoice_path(@invoice),
              :bill_address => @invoice.sales_order.customer.billing_address,
              :invoice_date => @invoice.created_at.to_date, 
              :invoice_items => invoice_item,
              :pending_credit_notes => pending_credit_notes,
              :currency => Setting.value_by('format.currency')
              }

    respond_to do |format|
      format.json {render :json => result}
    end
  end

  def credit_note
    params[:items].each do |index, item|
      if item[:quantity].to_i > 0
        invoice_extra_item = InvoiceExtraItem.new
        invoice_extra_item.quantity = item[:quantity]
        invoice_extra_item.invoice_id = @invoice.id
        invoice_extra_item.sales_item_id = item[:id].to_i
        invoice_extra_item.discount = item[:discount]
        invoice_extra_item.tax = item[:tax]
        invoice_extra_item.sub_total = item[:sub_total]
        invoice_extra_item.note = item[:note]
        invoice_extra_item.extra_type = (params[:type] == 'write_off') ? 0 : 1
        invoice_extra_item.total = item[:total]
        invoice_extra_item.customer_id = @invoice.sales_order.customer.id
        invoice_extra_item.save

        sales_item = SalesItem.find(item[:id])
        sales_item.confirm!
      end
    end

    @invoice.status = params[:type]
    @invoice.save

    @invoice.sales_order.invoice!(current_user)
    add_action_history('invoice', params[:type], @invoice.token)

    respond_to do |format|
      result = {:Result => "OK", 
                :Paid => @invoice.total_paid, 
                :Balance => @invoice.total - @invoice.total_paid,
                :CreditBalance => @invoice.total_credit_note, 
                :Status => @invoice.status_text.upcase, 
                :StatusClass => @invoice.status_class }
      format.json {render :json => result}
    end    
  end

  def remove_extra_item
    invoice = Invoice.find(params[:id])

    extra_items = []
    if params[:extra_item_type] == 'paid_back'
      extra_items = invoice.paid_extra_items
      extra_items.each do |item|
        sales_item_id = item.sales_item.id

        item.is_paid = 0
        item.paid_invoice_id = 0
        item.paid_invoice_type = invoice.class
        item.save

        sales_item = SalesItem.find(sales_item_id)
        sales_item.confirm!
      end      
    else
      extra_item = InvoiceExtraItem.find(params[:extra_item])
      unless extra_item.nil?
        extra_item.delete
      end
    end

    invoice.remove_extra_item!

    invoice.sales_order.invoice!(current_user)   

    redirect_to invoice_path(params[:id], type: params[:type])
  end

  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def add_action_history(action_name, action_type, action_number)
      @invoice.sales_order.action_histories.create!(action_name: action_name, 
                                            action_type: action_type, 
                                            action_number: action_number, 
                                            user: current_user)
    end

    def get_order_key
      params[:sort] = params[:sort].blank? ? 'desc' : params[:sort]
      case params[:order]
      when 'date'
        "invoices.created_at #{params[:sort]}"
      when 'order_no'
        "invoices.token #{params[:sort]}"
      when 'company'
        "customers.company_name #{params[:sort]}, customers.first_name #{params[:sort]}"
      when 'amount'
        "invoices.total_amount #{params[:sort]}"
      when 'status'
        "invoices.status #{params[:sort]}"
      else
        "invoices.created_at #{params[:sort]}"
      end      
    end 

    def get_sub_invoices
      case params[:type]
      when 'all'
        @invoices = Invoice.all.ordered
      when 'draft'
        @invoices = Invoice.draft.ordered
      when 'confirmed'
        @invoices = Invoice.confirmed.ordered
      when 'sent'
        @invoices = Invoice.sent.ordered
      when 'partial'
        @invoices = Invoice.partial.ordered
      when 'paid'
        @invoices = Invoice.paid.ordered
      else
        @invoices = Invoice.all.ordered
      end      
    end

    def set_sales_order
      @sales_order = SalesOrder.find(@invoice.sales_order_id)
    end
end
