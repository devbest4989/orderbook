class SuppliersController < ApplicationController
  before_action :set_supplier, only: [:show, :edit, :update, :destroy, :update_document, :update_contact]

  before_filter do
    locale = params[:locale]
    Carmen.i18n_backend.locale = locale if locale
  end

  # POST /supplier/1/info
  def detail_info
    @supplier = Supplier.find(params[:id])
    respond_to do |format|
      result = {:result => "OK", 
                :info => @supplier, 
                :billing => @supplier.billing_address, 
                :shipping =>@supplier.shipping_address }
      format.json {render :json => result}
    end
  end

  def bill_state
    render partial: 'select_bill_state'
  end

  def ship_state
    render partial: 'select_ship_state'
  end

  # GET /suppliers
  # GET /suppliers.json
  def index
    params[:key] = '' if params[:key].nil?
    if params[:key]
      @suppliers = Supplier.main_like(params[:key])
                  .paginate(page: params[:page])
    else
      @suppliers = Supplier.all.paginate(page: params[:page])
    end
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
    @suppliers = Supplier.all
    @purchase_orders = @supplier.purchase_orders.where.not(status: 'draft').ordered
  end

  # GET /suppliers/new
  def new
    @supplier = Supplier.new
    @suppliers = Supplier.all
  end

  # GET /suppliers/1/edit
  def edit
    @suppliers = Supplier.all
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    @supplier = Supplier.new(supplier_params)

    respond_to do |format|
      if @supplier.save
        if params[:documents]
          params[:documents].each do |doc| 
            @supplier.documents.create(:file => doc) 
          end 
        end
        format.html { redirect_to supplier_url(@supplier) }#, flash: {last_action: 'update_info', result: 'success'} }
        format.json { render :show, status: :created, location: @supplier }
      else
        format.html { render :new }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  rescue => ex
    redirect_to supplier_url(@supplier), flash: {last_action: 'update_info', result: 'failed', message: 'Saving information is failed.'}      
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update
    respond_to do |format|
      if @supplier.update(supplier_params)
        if params[:documents]
          params[:documents].each do |doc| 
            @supplier.documents.create(:file => doc) 
          end 
        end
        format.html { redirect_to edit_supplier_url(@supplier), flash: {last_action: 'update_info', result: 'success'} }
        format.json { render :show, status: :ok, location: @supplier }
      else
        format.html { render :edit }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  rescue => ex
    redirect_to edit_supplier_url(@supplier), flash: {last_action: 'update_info', result: 'failed', message: 'Updating information is failed.'}      
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update_document
    respond_to do |format|
      if params[:documents]
        params[:documents].each do |doc| 
          @supplier.documents.create(:file => doc) 
        end 
      end
      format.html { redirect_to edit_supplier_url(@supplier), flash: {last_action: 'update_document', result: 'success'} }
      format.json { render :show, status: :ok, location: @supplier }
    end
  rescue => ex
    redirect_to edit_supplier_url(@supplier), flash: {last_action: 'update_document', result: 'failed', message: 'Uploading documents is failed.'}  
  end

  # PATCH/PUT /suppliers/1
  # PATCH/PUT /suppliers/1.json
  def update_contact
    respond_to do |format|
      contact = Contact.new

      contact.first_name = params[:first_name]
      contact.last_name = params[:last_name]
      contact.mobile_number = params[:mobile_number]
      contact.landline_number = params[:landline_number]
      contact.email = params[:email]
      contact.designation = params[:designation]
      contact.supplier = @supplier

      if contact.save
        status = "OK"
      else
        status = "Error"
      end      
      result = {:Result => status, :Records => contact}
      format.json { render json: result }
    end
  end 

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    @supplier.destroy
    respond_to do |format|
      format.html { redirect_to suppliers_url, notice: 'Supplier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_supplier
      @supplier = Supplier.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def supplier_params
      params.require(:supplier).permit(
            :first_name, :last_name, 
            :company_name, :trading_name, 
            :company_reg_no, :company_gst_no, 
            :phone, :fax, :email, 
            :bill_street, :bill_suburb, :bill_city, :bill_state, :bill_postcode, :bill_country, 
            :ship_street, :ship_suburb, :ship_city, :ship_state, :ship_postcode, :ship_country, 
            :payment_term_id, 
            :documents,
            :bank_name, :bank_account_name, :bank_number,
            :contacts)
    end
end
