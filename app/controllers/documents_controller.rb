class DocumentsController < ApplicationController

  # GET /documents
  # GET /documents.json
  def index
    if params[:customer_id]
      @customer  = Customer.find(params[:customer_id])
      @documents = @customer.documents

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @documents }
      end
    elsif params[:supplier_id]
      @supplier  = Supplier.find(params[:supplier_id])
      @documents = @supplier.documents

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @documents }
      end      
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    if params[:customer_id]
      @customer  = Customer.find(params[:customer_id])
      @document = @customer.documents.build

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @document }
      end
    elsif params[:supplier_id]
      @supplier  = Supplier.find(params[:supplier_id])
      @document = @supplier.documents.build

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @document }
      end      
    end
  end

  # GET /documents/1/edit
  def edit
    @picture = Picture.find(params[:id])
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(params[:documents])

    if @document.save
      respond_to do |format|
        format.html {
          render :json => [@document.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json {
          render :json => [@document.to_jq_upload].to_json
        }
      end
    else
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update

    if params[:customer_id]
      @customer = Customer.find(params[:customer_id])
      @document = @customer.documents.find(params[:id])

      respond_to do |format|
        if @document.update_attributes(document_params)
          format.html { redirect_to customer_path(@customer), notice: 'Picture was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @document.errors, status: :unprocessable_entity }
        end
      end
    elsif params[:supplier_id]
      @supplier = Supplier.find(params[:supplier_id])
      @document = @supplier.documents.find(params[:id])

      respond_to do |format|
        if @document.update_attributes(document_params)
          format.html { redirect_to supplier_path(@supplier), notice: 'Picture was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @document.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document = Document.find(params[:id]);
    if @document.customer
      @customer = Customer.find(@document.customer.id)    
      @document.destroy
      respond_to do |format|
        format.html { redirect_to edit_customer_path(@customer), flash: {last_action: 'update_document', result: 'success'} }
        format.json { head :no_content }
      end
    else
      @supplier = Supplier.find(@document.supplier.id)    
      @document.destroy
      respond_to do |format|
        format.html { redirect_to edit_supplier_path(@supplier), flash: {last_action: 'update_document', result: 'success'} }
        format.json { head :no_content }      
      end
    end
  end

  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.require(:picture).permit(:customer_id, :supplier_id, :file)
    end
end
