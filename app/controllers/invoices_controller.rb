class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  # GET /invoices
  # GET /invoices.json
  def index
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
    get_sub_invoices
    set_sales_order

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
      @invoices = Invoice.all
                  .paginate(page: params[:page])
    when 'draft'
      @invoices = Invoice.where(status: 0)
                  .paginate(page: params[:page])
    when 'confirmed'
      @invoices = Invoice.where(status: 1)
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
    invoice.paid = params[:action_name] == 'update' ? 0 : params[:total] #params[:paid].to_f == 0 ? 0 : params[:paid]
    invoice.status = params[:action_name] == 'update' ? 0 : 1
    invoice.file_name = ''
    invoice.save

    invoice.invoice_items.delete_all
    params[:invoice_attributes].each do |elem|
      invoice_item = InvoiceItem.new
      invoice_item.invoice_id = invoice.id
      invoice_item.sales_item_id = elem[1][:id].to_i
      invoice_item.quantity   = elem[1][:quantity].to_i
      invoice_item.discount   = elem[1][:discount]
      invoice_item.tax        = elem[1][:tax]
      invoice_item.sub_total  = elem[1][:sub_total]
      invoice_item.save
    end

    add_action_history('invoice', 'update', invoice.token)
    @invoice.sales_order.invoice!(current_user)

    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice.invoice_items.delete_all
    @invoice.payments.delete_all
    @invoice.destroy
    add_action_history('invoice', 'delete', @invoice.token)
    @invoice.sales_order.confirm_status!

    respond_to do |format|
      format.html { redirect_to list_by_type_invoices_path(type: 'all')}
      result = {:Result => "OK" }
      format.json {render :json => result}
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
           :template => 'invoices/generate_pdf.pdf.haml',
           :layout => '/layouts/sales_order.pdf.haml',
           :locals => { 'invoice' => @invoice }
         )
      end
      @invoice.file_name = filename
      @invoice.save
    end

    redirect_path = '/invoices/' + @invoice.file_name
    redirect_to redirect_path

    # respond_to do |format|
    #   format.pdf do
    #     render pdf: "invoice", layout: '/layouts/sales_order.pdf.haml'
    #   end
    # end    
  end

  def print
  end

  def mail
  end

  def add_payment
    set_invoice
    payment = Payment.new
    payment.invoice_id = @invoice.id
    payment.payment_date = Date.strptime(params[:payment_date],  "%Y-%m-%d")
    payment.amount = params[:payment_amount]

    respond_to do |format|
      result = {}
      if payment.save
        @invoice.add_payment!
        result = {:Result => "OK" }
      else
        result = {:Result => "Failed" }
      end
      format.json {render :json => result}
    end
  end

  def approve
    set_invoice
    if @invoice.draft?
      @invoice.status = 'confirmed'
      @invoice.save
    end
    redirect_to invoice_path(@invoice, type: params[:type])
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
      case params[:order]
      when 'date'
        "invoices.order_date #{params[:sort]}"
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
