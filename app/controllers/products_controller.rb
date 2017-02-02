class ProductsController < ApplicationController
  include ActionView::Helpers::NumberHelper

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

    respond_to do |format|
      format.html { render "list" }
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
    generate_product_sku @product
    set_categories
    set_product_lines
    set_brands
    get_sub_produts
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
    get_sub_produts
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)
    @product.category = Category.find_or_create_by(name: params[:category_name].capitalize)
    @product.product_line = ProductLine.find_or_create_by(name: params[:product_line_name].capitalize)
    @product.brand = Brand.find_or_create_by(name: params[:brand_name].capitalize)    
    @product.warehouse = Warehouse.find_or_create_by(name: params[:warehouse_name].capitalize)    

    respond_to do |format|
      if @product.save
        generate_product_sku
        save_product_prices
        format.html { redirect_to product_path(@product), notice: 'Product was successfully created.' }
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
    @product.category = Category.find_or_create_by(name: params[:category_name].capitalize)
    @product.product_line = ProductLine.find_or_create_by(name: params[:product_line_name].capitalize)
    @product.brand = Brand.find_or_create_by(name: params[:brand_name].capitalize)
    @product.warehouse = Warehouse.find_or_create_by(name: params[:warehouse_name].capitalize)    

    respond_to do |format|
      if @product.update(product_params)
        generate_product_sku @product
        save_product_prices
        format.html { redirect_to product_path(@product), notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        get_sub_produts
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

  def action
    case params[:action_name]
    when 'status'
      set_invert_status
      redirect_to product_path(@product)
    when 'clone'
      set_clone_product
      render 'new'
    end    
  end

  def upload_file
    build_products_from_excel_file
    build_products_from_csv_file
    redirect_to list_by_type_products_path('all')
  end

  def download  
    order_key = get_order_key
    params[:key] = '' if params[:key].nil?
    case params[:type]
    when 'all'
      @products = Product.all.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
    when 'active'
      @products = Product.actived.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
    when 'inactive'
      @products = Product.inactived.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
    when 'removed'
      @products = Product.removed.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
    when 'varient'
      @products = Product.all.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
    when 'low-stock'
      @products = Product.all.main_like(params[:key])
                  .includes(:product_line)
                  .includes(:category)
                  .includes(:brand)
                  .order(order_key)
    else
      @products = Product.all.order(order_key)
    end

    col_names = []
    col_names << 'Barcode'
    col_names << 'Item Name'
    col_names << 'Brand'
    col_names << 'Category'
    col_names << 'Product Line'
    col_names << 'Re-oder Point'
    col_names << 'Opening Stock'
    col_names << 'Purchase Price'
    col_names << 'Retail Price'
    col_names << 'RRP-Markup%'
    col_names << 'RRP-GP%'
    col_names << 'Wholesale Price'
    col_names << 'WS-Mark-up %'
    col_names << 'WS-GP %'
    col_names << 'Stock Location'
    col_names << 'Stock Status'
    col_names << 'State'
    col_names << 'TaxType'

    csv_data = CSV.generate({}) do |csv|
      csv.add_row col_names
      @products.each do |item|
        row_values = []
        row_values << item.barcode
        row_values << item.name
        row_values << item.brand.name
        row_values << item.category.name
        row_values << item.product_line.name
        row_values << item.reorder_qty
        row_values << item.open_qty
        row_values << item.main_purchase_price
        row_values << item.main_selling_price
        row_values << calculate_mp(item.main_purchase_price, item.main_selling_price)
        row_values << calculate_gp(item.main_purchase_price, item.main_selling_price)

        wholeprice = item.prices.where(name: 'Wholesale').first
        if wholeprice.nil?
          row_values << ''
          row_values << ''
          row_values << ''
        else
          row_values << wholeprice.value
          row_values << calculate_mp(item.main_purchase_price, wholeprice.value)
          row_values << calculate_gp(item.main_purchase_price, wholeprice.value)
        end
        row_values << item.warehouse.name
        row_values << item.stock_status_text
        row_values << item.status_label
        row_values << item.selling_tax.name
        csv.add_row row_values
      end
    end

    respond_to do |format|
      format.csv {send_data csv_data, filename: 'products.csv'}
    end
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

    def set_invert_status
      @product = Product.find(params[:id])
      @product.status = !@product.status
      @product.save
    end

    def set_clone_product
      old_product = Product.find(params[:id])
      @product = old_product.dup      
      #@product.save

      old_product.prices.each do |item|
        new_price = @product.prices.new(product_id: @product.id, name: item.name, price_type: item.price_type, value: item.value)
      end
    end

    def save_product_prices
      Price.where(product_id: @product.id).destroy_all
      unless params[:product][:prices_attributes].nil? 
        params[:product][:prices_attributes].each do |index, item| 
          price = @product.prices.new(name: item[:name], value: item[:value], price_type: @product.selling_price_type)
          price.save
        end        
      end
    end

    def generate_product_sku product
      sku_string = ""

      sku_string += product.category.name[0].upcase unless product.category.nil?
      sku_string += product.brand.name[0].upcase unless product.brand.nil?

      name_array = product.name.split(' ')
      name_array.each do |item|
        sku_string += item[0].upcase if %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z).include? (item[0].upcase)
      end

      product.sku = sku_string + product.id.to_s
      product.save
    end

    def create_product_prices
      params[:product][:prices_attributes].each do |index, elem|
        price = Price.where(product_id: @product.id, name: elem[:name]).first
        unless price.nil?
          price.destroy_all
        end
        price = @product.prices.new(name: elem[:name], value: elem[:value], price_type: @product.selling_price_type)
        price.save          
      end
    end

    def calculate_mp (purchase, selling)
      number_to_percentage((selling - purchase) * 100 / purchase, precision: 2)
    end

    def calculate_gp (purchase, selling)
      number_to_percentage((selling - purchase) * 100 / selling, precision: 2)
    end

    def get_sub_produts
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

    def build_products_from_csv_file
      file_data = params[:csv_file]
      if file_data
        CSV.foreach(file_data.path, headers: true) do |row|
          product = Product.find_by(barcode: row[0])
          if product.nil? 
            product = Product.new
          end
          product.barcode = row[0]
          product.name = row[1] unless row[1].blank?
          product.description = ''
          product.brand = Brand.find_or_create_by(name: row[2].capitalize) unless row[2].blank?
          product.category = Category.find_or_create_by(name: row[3].capitalize) unless row[3].blank?
          product.product_line = ProductLine.find_or_create_by(name: row[4].capitalize) unless row[4].blank?
          product.warehouse = Warehouse.find_or_create_by(name: row[14].capitalize) unless row[14].blank?
          product.reorder_qty = row[5].to_i unless row[5].blank?
          product.open_qty = row[6].to_i unless row[6].blank?
          product.selling_tax = Tax.find_by(name: row[17])
          product.purchase_tax = Tax.find_by(name: row[17])

          purchase_value = 0
          sell_value = 0
          unless row[7].blank?                
            purchase_value = (row[7].strip.chars.first == '$') ? row[7].slice!(1..-1).to_f : row[7].to_f
            product.purchase_price_ex = purchase_value
            product.purchase_price = (product.purchase_tax.nil?) ? purchase_value : purchase_value * (product.purchase_tax.rate + 100) * 0.01
          end

          if row[8].blank? && !row[9].blank?
            product.selling_price = product.purchase_price_ex * (100 + row[9].to_f) * 0.01
            product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
          elsif !row[8].blank?
            sell_value = (row[8].strip.chars.first == '$') ? row[8].slice!(1..-1).to_f : row[8].to_f
            product.selling_price = sell_value
            product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
          end
          product.selling_price_type  = false
          product.purchase_price_type = true
          product.quantity = row[6].to_i unless row[6].blank?
          product.save

          price = (product.prices.nil?) ? nil : product.prices.find_by(name: "Wholesale");
          if price.nil?
            price = product.prices.new(name: "Wholesale")
          end
          price.price_type = 0

          if row[11].blank? && !row[12].blank?
            price.value = product.purchase_price_ex * (100 + row[12].to_f) * 0.01
          elsif !row[11].blank?
            sell_value = (row[11].strip.chars.first == '$') ? row[11].strip.slice!(1..-1).to_f : row[11].to_f
            price.value = sell_value
          end
          price.save

          generate_product_sku product
        end
      end
    end

    def build_products_from_excel_file
      file_data = params[:excel_file]

      if file_data
        xlsx = Roo::Spreadsheet.open(file_data.path, extension: :xlsx)
        if xlsx.sheets.count > 0
          if xlsx.last_row > 1
            2.upto(xlsx.last_row) do |line|              
              product = Product.find_by(barcode: xlsx.cell(line, 'A').to_s.strip)
              if product.nil? 
                product = Product.new
              end
              product.barcode = xlsx.cell(line, 'A').to_s.strip unless xlsx.cell(line, 'A').nil?
              product.name = xlsx.cell(line, 'B').to_s.strip unless xlsx.cell(line, 'B').nil?
              product.description = ''
              product.brand = Brand.find_or_create_by(name: xlsx.cell(line, 'C').to_s.strip.capitalize) unless xlsx.cell(line, 'C').nil?
              product.category = Category.find_or_create_by(name: xlsx.cell(line, 'D').to_s.strip.capitalize) unless xlsx.cell(line, 'D').nil?
              product.product_line = ProductLine.find_or_create_by(name: xlsx.cell(line, 'E').to_s.strip.capitalize) unless xlsx.cell(line, 'E').nil?
              product.warehouse = Warehouse.find_or_create_by(name: xlsx.cell(line, 'O').to_s.strip.capitalize) unless xlsx.cell(line, 'O').nil?
              product.reorder_qty = xlsx.cell(line, 'F').to_i unless xlsx.cell(line, 'F').nil?
              product.open_qty = xlsx.cell(line, 'G').to_i unless xlsx.cell(line, 'G').nil?
              product.selling_tax = Tax.find_by(name: xlsx.cell(line, 'R'))
              product.purchase_tax = Tax.find_by(name: xlsx.cell(line, 'R'))

              purchase_value = 0
              sell_value = 0
              unless xlsx.cell(line, 'H').nil?                
                purchase_value = (xlsx.cell(line, 'H').to_s.strip.chars.first == '$') ? xlsx.cell(line, 'H').to_s.strip.slice!(1..-1).to_f : xlsx.cell(line, 'H').to_f
                product.purchase_price_ex = purchase_value
                product.purchase_price = (product.purchase_tax.nil?) ? purchase_value : purchase_value * (product.purchase_tax.rate + 100) * 0.01
              end

              if xlsx.cell(line, 'I').nil? && !xlsx.cell(line, 'J').nil?
                product.selling_price = product.purchase_price_ex * (100 + xlsx.cell(line, 'J').to_f) * 0.01
                product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
              elsif !xlsx.cell(line, 'I').nil?
                sell_value = (xlsx.cell(line, 'I').to_s.strip.chars.first == '$') ? xlsx.cell(line, 'I').to_s.strip.slice!(1..-1).to_f : xlsx.cell(line, 'I').to_f
                product.selling_price = sell_value
                product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
              end
              product.selling_price_type  = false
              product.purchase_price_type = true
              product.quantity = xlsx.cell(line, 'G').to_i unless xlsx.cell(line, 'G').nil?
              product.save

              price = (product.prices.nil?) ? nil : product.prices.find_by(name: "Wholesale");
              if price.nil?
                price = product.prices.new(name: "Wholesale")
              end
              price.price_type = 0

              if xlsx.cell(line, 'L').nil? && !xlsx.cell(line, 'M').nil?
                price.value = product.purchase_price_ex * (100 + xlsx.cell(line, 'M').to_f) * 0.01
              elsif !xlsx.cell(line, 'L').nil?
                sell_value = (xlsx.cell(line, 'L').to_s.strip.chars.first == '$') ? xlsx.cell(line, 'L').to_s.strip.slice!(1..-1).to_f : xlsx.cell(line, 'L').to_f
                price.value = sell_value
              end
              price.save

              generate_product_sku product
            end        
          end
        end
      end
    end
end
