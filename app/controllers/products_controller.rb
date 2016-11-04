class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # POST /products/list_by_sku
  def list_by_sku
    if params[:term]
      @products = Product.select('sku as text, id').sku_like(params[:term])
    end

    respond_to do |format|
      result = {:Result => "OK", :Records => @products}
      format.json {render :json => result}
    end
  end

  # POST /products/list_by_sku
  def list_by_id
    if params[:id]
      @product = Product.select('sku, id, name, selling_price').find(params[:id])
    end

    respond_to do |format|
      format.json {render :json => @product}
    end
  end

  # POST /products/list_by_name
  def list_by_name
    if params[:term]
      @products = Product.select('name as text, id').name_like(params[:term])
    end

    respond_to do |format|
      result = {:Result => "OK", :Records => @products}
      format.json {render :json => result}
    end
  end

  # POST /products/list
  def list
    orderString = (params[:jtSorting]) ? params[:jtSorting] : "id ASC"
    if params[:name] || params[:sku] || params[:category_id] || params[:brand_id] || params[:product_line_id]
      @products = Product.name_like(params[:name])
                  .sku_like(params[:sku])
                  .by_category(params[:category_id])
                  .by_brands(params[:brand_id])
                  .by_line(params[:product_line_id])
                  .order(orderString)
    else
      @customers = Product.all.order(orderString)
    end

    if params[:jtStartIndex] && params[:jtPageSize]
      @products.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @products.count, :Records => @products}
      format.json {render :json => result}
    end
  end

  # POST /products/remove
  def remove
    @product = Product.find(params[:id])        
    respond_to do |format|
      if @product.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@product.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /products/change
  def change
    @product = Product.find(params[:id])    
    @product.name = params[:name]
    @product.sku = params[:sku]
    @product.description = params[:description]
    @product.category = Category.find(params[:category_id])
    @product.product_line = ProductLine.find(params[:product_line_id])
    @product.perchase_price = BigDecimal.new(params[:perchase_price])
    @product.selling_price = BigDecimal.new(params[:selling_price])
    @product.quantity = params[:quantity]
    @product.brand = Brand.find(params[:brand_id])
    
    respond_to do |format|
      if @product.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@product.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /products/append
  def append
    @product = Product.new
    @product.name = params[:name]
    @product.sku = params[:sku]
    @product.description = params[:description]
    @product.category = Category.find(params[:category_id])
    @product.product_line = ProductLine.find(params[:product_line_id])
    @product.perchase_price = BigDecimal.new(params[:perchase_price])
    @product.selling_price = BigDecimal.new(params[:selling_price])
    @product.quantity = params[:quantity]
    @product.brand = Brand.find(params[:brand_id])

    respond_to do |format|
      if @product.save
        result = {:Result => "OK", :Record => @product}
      else
        result = {:Result => "ERROR", :Message =>@product.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:sku, :name, :description)
    end
end
