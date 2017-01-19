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
      @products = Product.all.order(orderString)
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
    @product.brand = Brand.find(params[:brand_id])
    @product.purchase_price = BigDecimal.new(params[:purchase_price])
    @product.selling_price = BigDecimal.new(params[:selling_price])
    @product.quantity = params[:quantity]
    
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
    @product.purchase_price = BigDecimal.new(params[:purchase_price])
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

  def list_by_type    
    set_categories
    set_product_lines
    set_brands
    order_key = get_order_key
    params[:key] = '' if params[:key].nil?
    case params[:type]
    when 'all'
      @products = Product.all.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'active'
      @products = Product.actived.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'inactive'
      @products = Product.inactived.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'removed'
      @products = Product.removed.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'varient'
      @products = Product.all.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
                  .paginate(page: params[:page])
    when 'low-stock'
      @products = Product.all.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
                  .paginate(page: params[:page])
    else
      @products = Product.all.order(order_key)
    end

    render "list"
  end

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show    
    set_categories
    set_product_lines
    set_brands
    case params[:type]
    when 'all'
      @products = Product.all.ordered
    when 'active'
      @products = Product.actived.ordered
    when 'inactive'
      @products = Product.inactived.ordered
    when 'varient'
      @products = Product.all.ordered
    when 'low-stock'
      @products = Product.all.ordered
    else
      @products = Product.all.ordered
    end
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
    set_categories
    set_product_lines
    set_brands
    case params[:type]
    when 'all'
      @products = Product.all
    when 'active'
      @products = Product.actived
    when 'inactive'
      @products = Product.inactived
    when 'varient'
      @products = Product.all
    when 'low-stock'
      @products = Product.all
    else
      @products = Product.all
    end
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.category = Category.find_or_create_by(name: params[:category_name])
    @product.product_line = ProductLine.find_or_create_by(name: params[:product_line_name])
    @product.brand = Brand.find_or_create_by(name: params[:brand_name])    

    respond_to do |format|
      if @product.save
        generate_product_sku
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
    @product.category = Category.find_or_create_by(name: params[:category_name])
    @product.product_line = ProductLine.find_or_create_by(name: params[:product_line_name])
    @product.brand = Brand.find_or_create_by(name: params[:brand_name])
    respond_to do |format|
      if @product.update(product_params)
        generate_product_sku
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
    @product.removed = true
    @product.save
    respond_to do |format|
      format.html { redirect_to list_by_type_products_path('removed'), notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def bulk_action
    case params[:bulk_action]
    when '1'
      @products = Product.where("products.id IN (#{params[:product_ids]})")
      @products.each do |item|
        item.removed = false
        item.status = true
        item.save
      end
    when '2'
      @products = Product.where("products.id IN (#{params[:product_ids]})")
      @products.each do |item|
        item.removed = false
        item.status = false
        item.save
      end
    when '3'
      @products = Product.where("products.id IN (#{params[:product_ids]})")
      @products.each do |item|
        item.removed = true
        item.save
      end
    end
      
    redirect_to list_by_type_products_path(type: params[:type], key: params[:key], sort: params[:sort], order: params[:order])
  end

  def upload_file
    build_products_from_file
    redirect_to list_by_type_products_path('all')
  end

  def download

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:barcode, :name, :description, :selling_price, :purchase_price, :image,
                                      :selling_price_ex, :purchase_price_ex, :selling_tax_id, :purchase_tax_id, :selling_price_type, :purchase_price_type,
                                      :reorder_qty, :quantity)
    end

    def set_categories
      @categories = Category.all
    end

    def set_product_lines
      @product_lines = ProductLine.all
    end

    def set_brands
      @brands = Brand.all
    end

    def get_order_key
      case params[:order]
      when 'name'
        "products.name #{params[:sort]}"
      when 'line'
        "product_lines.name #{params[:sort]}"
      when 'qty'
        "products.quantity #{params[:sort]}"
      when 'price'
        "products.selling_price #{params[:sort]}"
      when 'status'
        "products.quantity #{params[:sort]}"
      when 'category'
        "categories.name #{params[:sort]}"
      when 'brand'
        "brands.name #{params[:sort]}"
      else
        "products.created_at #{params[:sort]}"
      end      
    end

    def generate_product_sku
      name_array = @product.name.split(' ')
      category_array = @product.category.name.split(' ')
      
      sku_string = ""
      name_array.each do |item|
        sku_string += item[0].upcase
      end

      sku_string += '-'

      category_array.each do |item|
        sku_string += item[0].upcase
      end

      @product.sku = sku_string + '-' + @product.id.to_s
      @product.save
    end

    def build_products_from_file
      file_data = params[:excel_file]

      if file_data
        xlsx = Roo::Spreadsheet.open(file_data.path, extension: :xlsx)
        if xlsx.sheets.count > 0
          if xlsx.last_row > 1
            2.upto(xlsx.last_row) do |line|              
              product = Product.find_by(name: xlsx.cell(line, 'B').strip)
              if product.nil? 
                product = Product.new
              end
              product.sku = xlsx.cell(line, 'A').strip unless xlsx.cell(line, 'A').nil?
              product.name = xlsx.cell(line, 'B').strip unless xlsx.cell(line, 'B').nil?
              product.description = ''
              product.brand = Brand.find_or_create_by(name: xlsx.cell(line, 'C').strip) unless xlsx.cell(line, 'C').nil?
              product.category = Category.find_or_create_by(name: xlsx.cell(line, 'D').strip) unless xlsx.cell(line, 'D').nil?
              product.product_line = ProductLine.find_or_create_by(name: xlsx.cell(line, 'E').strip) unless xlsx.cell(line, 'E').nil?
              product.purchase_price_ex = xlsx.cell(line, 'F').to_f
              product.selling_price_ex = xlsx.cell(line, 'G').to_f
              product.selling_tax = Tax.all.first
              product.purchase_tax = Tax.all.first
              product.purchase_price = xlsx.cell(line, 'F').to_f * (product.purchase_tax.rate + 100) / 100.0
              product.selling_price = xlsx.cell(line, 'G').to_f * (product.selling_tax.rate + 100) / 100.0              
              product.selling_price_type  = false
              product.purchase_price_type = false
              product.quantity = 0
              product.reorder_qty = 0
              product.save
            end        
          end
        end
      end
    end
end
