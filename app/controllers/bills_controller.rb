class BillsController < ApplicationController
  before_action :set_bill, only: [:show, :edit, :update, :destroy]

  # GET /bills
  # GET /bills.json
  def index
  end

  # GET /bills/1
  # GET /bills/1.json
  def show
    get_sub_bills
    set_purchase_order

    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end    
  end

  # GET /bills/new
  def new
  end

  # GET /bills/1/edit
  def edit
  end

  # POST /bills
  # POST /bills.json
  def create
  end

  def list_by_type
    order_key = get_order_key
    case params[:type]
    when 'all'
      @bills = Bill.where.not(purchase_order_id: 0)
                  .paginate(page: params[:page])
    when 'draft'
      @bills = Bill.where.not(purchase_order_id: 0).where(status: 0)
                  .paginate(page: params[:page])
    when 'confirmed'
      @bills = Bill.where.not(purchase_order_id: 0).where(status: 1)
                  .paginate(page: params[:page])
    when 'sent'
      @bills = Bill.where.not(purchase_order_id: 0).where(status: 2)
                  .paginate(page: params[:page])
    when 'partial'
      @bills = Bill.where.not(purchase_order_id: 0).where(status: 3)
                  .paginate(page: params[:page])
    when 'paid'
      @bills = Bill.where.not(purchase_order_id: 0).where(status: 4)
                  .paginate(page: params[:page])
    end

    respond_to do |format|
      format.html { render "list" }
    end
  end

  # PATCH/PUT /bills/1
  # PATCH/PUT /bills/1.json
  def update
    bill = Bill.find(params[:id])
    bill.sub_total = params[:sub_total]
    bill.discount = params[:discount_total]
    bill.tax = params[:tax_total]
    bill.total = params[:total]
    # bill.paid = params[:action_name] == 'update' ? 0 : params[:total] #params[:paid].to_f == 0 ? 0 : params[:paid]
    # bill.status = params[:action_name] == 'update' ? 0 : 1
    bill.file_name = ''
    bill.save

    bill.bill_items.delete_all
    params[:bill_attributes].each do |elem|
      bill_item = BillItem.new
      bill_item.bill_id = bill.id
      bill_item.quantity   = elem[1][:quantity].to_i
      bill_item.discount   = elem[1][:discount]
      bill_item.tax        = elem[1][:tax]
      bill_item.sub_total  = elem[1][:sub_total]
      bill_item.purchase_item_id = (elem[1][:type] == 'product') ? elem[1][:id].to_i : 0
      bill_item.purchase_custom_item_id = (elem[1][:type] != 'product') ? elem[1][:id].to_i : 0
      bill_item.save
    end

    add_action_history('bill', 'update', bill.token)

    bill.purchase_order.bill!(current_user)

    respond_to do |format|
      result = {:Result => "OK" }
      format.json {render :json => result}
    end
  end

  # DELETE /bills/1
  # DELETE /bills/1.json
  def destroy
    @bill.purchase_order.confirm_status!
    @bill.bill_items.destroy_all
    @bill.payments.destroy_all
    @bill.destroy
    add_action_history('bill', 'delete', @bill.token)

    respond_to do |format|
      if request.xhr?
        result = {:Result => "OK" }
        format.json {render :json => result}
      else
        format.html { redirect_to list_by_type_bills_path(type: 'all')}
      end
    end
  end

  def generate_pdf
    set_bill
    # Self Company Profile
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end

    if @bill.file_name.blank? || @bill.is_updated_pdf
      begin
        filename = SecureRandom.hex(10) + '_' + @bill.updated_at.to_i.to_s + '.pdf'
      end while Bill.exists?(:file_name => filename)      

      save_path = Rails.root.join('public/bills', filename)
      File.open(save_path, 'wb') do |file|
        file << render_to_string(
           :pdf => "bill",         
           :page_size => "A4",
           :template => 'bills/generate_pdf.pdf.haml',
           :layout => '/layouts/bill.pdf.haml',
           :locals => { 'bill' => @bill },
           :header =>{
              :html =>{
                :template => 'bills/header.pdf.haml',
                :locals => { 'bill' => @bill },
              },
              :spacing => 0
           },
           :footer =>{
              :html =>{
                :template => 'bills/footer.pdf.haml',
                :locals => { 'bill' => @bill },
              },
              :spacing => 0
           }           
         )
      end
      @bill.file_name = filename
      @bill.save
    end

    redirect_path = '/bills/' + @bill.file_name
    redirect_to redirect_path

    # respond_to do |format|
    #   format.pdf do
    #     render pdf: "bill", layout: '/layouts/bill.pdf.haml'
    #   end
    # end    
  end

  def print
  end

  def mail
  end

  def remove_payment
    payment = BillPayment.find(params[:payment])
    payment.delete

    bill = Bill.find(params[:id])
    bill.remove_payment!

    redirect_to bill_path(params[:id], type: params[:type])
  end

  def add_payment
    set_bill
    payment = BillPayment.new
    payment.bill_id = @bill.id
    payment.payment_date = Date.strptime(params[:payment_date],  "%d-%m-%Y")
    payment.amount = params[:payment_amount]
    payment.payment_mode = params[:payment_mode]
    payment.reference_no = params[:reference_no]
    payment.note = params[:note]

    respond_to do |format|
      result = {}
      if payment.save
        @bill.add_payment!
        result = {:Result => "OK", :Balance => @bill.total - @bill.total_paid, :Status => @bill.status_text.upcase, :StatusClass => @bill.status_class }
      else
        result = {:Result => "Failed", :Message => payment.errors.full_messages }
      end
      format.json {render :json => result}
    end
  end

  def approve
    set_bill
    if @bill.draft?
      @bill.status = 'confirmed'
      @bill.save
    end

    if request.xhr?
      respond_to do |format|
        result = {:Result => "OK" }
        format.json {render :json => result}
      end      
    else
      redirect_to bill_path(@bill, type: params[:type])
    end
  end

  private
    def set_bill
      @bill = Bill.find(params[:id])
    end

    def add_action_history(action_name, action_type, action_number)
      @bill.purchase_order.action_histories.create!(action_name: action_name, 
                                            action_type: action_type, 
                                            action_number: action_number, 
                                            user: current_user)
    end

    def get_order_key
      case params[:order]
      when 'date'
        "bills.order_date #{params[:sort]}"
      when 'order_no'
        "bills.token #{params[:sort]}"
      when 'company'
        "customers.company_name #{params[:sort]}, customers.first_name #{params[:sort]}"
      when 'amount'
        "bills.total_amount #{params[:sort]}"
      when 'status'
        "bills.status #{params[:sort]}"
      else
        "bills.created_at #{params[:sort]}"
      end      
    end 

    def get_sub_bills
      case params[:type]
      when 'all'
        @bills = Bill.all.ordered
      when 'draft'
        @bills = Bill.draft.ordered
      when 'confirmed'
        @bills = Bill.confirmed.ordered
      when 'sent'
        @bills = Bill.sent.ordered
      when 'partial'
        @bills = Bill.partial.ordered
      when 'paid'
        @bills = Bill.paid.ordered
      else
        @bills = Bill.all.ordered
      end      
    end

    def set_purchase_order
      @purchase_order = PurchaseOrder.find(@bill.purchase_order_id)
    end
end
