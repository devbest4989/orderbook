class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy, :update_document, :update_contact]

  before_filter do
    locale = params[:locale]
    Carmen.i18n_backend.locale = locale if locale
  end

  # POST /customer/1/info
  def detail_info
    @customer = Customer.find(params[:id])
    respond_to do |format|
      result = {:result => "OK", :phone => @customer.phone, :fax => @customer.fax, :email => @customer.email, :billing => @customer.billing_address, :shipping =>@customer.shipping_address }
      format.json {render :json => result}
    end
  end

  def bill_state
    render partial: 'select_bill_state'
  end

  def ship_state
    render partial: 'select_ship_state'
  end

  # GET /customers
  # GET /customers.json
  def index
    if params[:key]
      @customers = Customer.main_like(params[:key])
                  .paginate(page: params[:page])
    else
      @customers = Customer.all.paginate(page: params[:page])
    end    
  end

  # GET /customers/1
  # GET /customers/1.json
  def show    
    @customers = Customer.all
    @sales_orders = @customer.sales_orders
  end

  # GET /customers/new
  def new
    @customer = Customer.new
    @customers = Customer.all
  end

  # GET /customers/1/edit
  def edit
    @customers = Customer.all
  end

  # POST /customers
  # POST /customers.json
  def create    
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        if params[:documents]
          params[:documents].each do |doc| 
            @customer.documents.create(:file => doc) 
          end 
        end
        format.html { redirect_to customer_url(@customer) }#, flash: {last_action: 'update_info', result: 'success'} }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  rescue => ex
    redirect_to customer_url(@customer), flash: {last_action: 'update_info', result: 'failed', message: 'Saving information is failed.'}      
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        if params[:documents]
          params[:documents].each do |doc| 
            @customer.documents.create(:file => doc) 
          end 
        end
        format.html { redirect_to edit_customer_url(@customer), flash: {last_action: 'update_info', result: 'success'} }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  rescue => ex
    redirect_to edit_customer_url(@customer), flash: {last_action: 'update_info', result: 'failed', message: 'Updating information is failed.'}      
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update_document
    respond_to do |format|
      if params[:documents]
        params[:documents].each do |doc| 
          @customer.documents.create(:file => doc) 
        end 
      end
      format.html { redirect_to edit_customer_url(@customer), flash: {last_action: 'update_document', result: 'success'} }
      format.json { render :show, status: :ok, location: @customer }
    end
  rescue => ex
    redirect_to edit_customer_url(@customer), flash: {last_action: 'update_document', result: 'failed', message: 'Uploading documents is failed.'}  
  end

  # PATCH/PUT /customers/1
  # PATCH/PUT /customers/1.json
  def update_contact
    respond_to do |format|
      contact = Contact.new

      contact.first_name = params[:first_name]
      contact.last_name = params[:last_name]
      contact.mobile_number = params[:mobile_number]
      contact.landline_number = params[:landline_number]
      contact.email = params[:email]
      contact.designation = params[:designation]
      contact.customer = @customer

      if contact.save
        status = "OK"
      else
        status = "Error"
      end      
      result = {:Result => status, :Records => contact}
      format.json { render json: result }
    end
  end 

  # DELETE /customers/1
  # DELETE /customers/1.json
  def destroy
    @customer.destroy
    respond_to do |format|
      format.html { redirect_to customers_url, notice: 'Customer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def customer_params
      params.require(:customer).permit(
            :first_name, :last_name, 
            :company_name, :trading_name, 
            :company_reg_no, :company_gst_no, 
            :phone, :fax, :email, 
            :bill_street, :bill_suburb, :bill_city, :bill_state, :bill_postcode, :bill_country, 
            :ship_street, :ship_suburb, :ship_city, :ship_state, :ship_postcode, :ship_country, 
            :payment_term,
            :documents,
            :contacts)
    end
end
