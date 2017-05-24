class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  # GET /invoices
  # GET /invoices.json
  def index
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
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
    @invoice.destroy
    add_action_history('invoice', 'delete', @invoice.token)
    @invoice.sales_order.confirm_status!

    respond_to do |format|
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

end
