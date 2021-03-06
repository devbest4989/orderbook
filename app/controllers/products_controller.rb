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
      @product = Product.select('sku, id, name, selling_price_ex, selling_tax_id').includes(:selling_tax).includes(:prices).find(params[:id])
    end

    respond_to do |format|
      price = @product.prices.where("LOWER(name) = ?", params[:price_name].downcase).first
      price_value = (price.nil?) ? 'nil' : price.price_tax_exclude
      format.json {render :json => {product: @product, 
                                    tax: @product.selling_tax, 
                                    price: price_value}
                  }
    end
  end

  # POST /products/list_by_sku
  def list_purchase_by_id
    if params[:id]
      @product = Product.select('sku, id, name, purchase_price_ex, purchase_tax_id').includes(:purchase_tax).find(params[:id])
    end

    respond_to do |format|
      format.json {render :json => {product: @product, 
                                    tax: @product.purchase_tax}
                  }
    end
  end

  # POST /products/list_by_name
  def list_by_name

    # if params[:key]
    #   @products = Product.actived.name_code_like(params[:key])
    #               .joins(:brand)
    #               .ordered
    #               .select('products.name as name, 
    #                        products.id as id, 
    #                        products.sku as sku, 
    #                        products.quantity as quantity, 
    #                        products.barcode as barcode, 
    #                        brands.name as brand_name')
    # end

    # respond_to do |format|
    #   result = {:Result => "OK", :data => {product: @products} }
    #   format.json {render :json => result}
    # end

    if params[:term]
      @products = Product.select('name as text, id').actived.name_like(params[:term])
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

    unless params[:category_id].nil? 
      @products = @products.by_category(params[:category_id]) 
    end

    unless params[:brand_id].nil? 
      @products = @products.by_brands(params[:brand_id]) 
    end

    unless params[:product_line_id].nil? 
      @products = @products.by_line(params[:product_line_id]) 
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
    set_categories
    set_product_lines
    set_brands
    get_sub_produts
    set_movement_items
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

    similar_count = Product.find_by(slug: @product.name.parameterize)

    @product.slug = (similar_count.nil?) ? @product.name.parameterize : @product.name.parameterize + "-" + Time.now.to_i.to_s

    respond_to do |format|
      if @product.save
        save_product_variant unless params[:variants].nil? 
        save_sub_product unless params[:sub_product].nil? 
        save_single_sub_product if params[:sub_product].nil? 
        save_sub_product_prices
        save_product_unit unless params[:product_unit].nil? 
        @product.stock!
        
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
    update_product_units

    respond_to do |format|
      if @product.update(product_params)
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
                                      :reorder_qty, :quantity, :open_qty)
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

    def save_sub_product_prices
      Price.where(product_id: @product.id).destroy_all
      unless params[:product][:prices_attributes].nil? 
        params[:product][:prices_attributes].each do |index, item| 
          @product.sub_products.each do |elem|
            price = elem.prices.new(name: item[:name], value: item[:value], price_type: @product.selling_price_type, product_id: @product.id)
            price.save
          end
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

    def generate_sub_product_sku elem
      # @product.sub_products.each do |elem|
        sku_string = ""

        sku_string += @product.category.name[0].upcase unless @product.category.nil?
        sku_string += @product.brand.name[0].upcase unless @product.brand.nil?

        name_array = @product.name.split(' ')
        name_array.each do |item|
          sku_string += item[0].upcase if %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z).include? (item[0].upcase)
        end

        sku_string += "-" + elem.value1.strip.upcase.first(5) unless elem.value1.blank?
        sku_string += "-" + elem.value2.strip.upcase.first(5) unless elem.value1.blank?
        sku_string += "-" + elem.value3.strip.upcase.first(5) unless elem.value1.blank?

        return sku_string + elem.id.to_s        
      # end
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

    def set_movement_items
      sql = "
        SELECT pr.*
        FROM
        (
            (
            SELECT
                pr.id id,
                pr.created_at move_date,
                '-' token,
                0 order_id,
                'Open Quantity' customer_name,
                0 customer_id,
                SUM(sp.open_qty) quantity,
                '' as status,
                'Open' as type,
                '' as value1,
                '' as value2,
                '' as value3
            FROM products pr
            LEFT JOIN sub_products sp ON sp.product_id = pr.id
            WHERE
                pr.id = #{params[:id]}
            GROUP BY pr.id
            )
            UNION ALL
            (
            SELECT 
                pr.id id,
                so.order_date move_date,
                so.token token,
                so.id order_id,
                concat(cu.first_name, ' ', cu.last_name) as customer_name,
                cu.id customer_id,
                si.quantity as quantity,
                so.status as status,
                'Sale Order' as type,
                pr.value1 as value1,
                pr.value2 as value2,
                pr.value3 as value3
            FROM sub_products pr
            LEFT JOIN sales_items si ON pr.id = si.sold_item_id
            LEFT JOIN sales_orders so ON si.sales_order_id = so.id
            LEFT JOIN customers cu ON so.customer_id = cu.id
            WHERE so.status <> 'quote' AND pr.product_id = #{params[:id]}
            )
            UNION ALL
            (
            SELECT 
                pr.id id,
                po.order_date move_date,
                po.token token,
                po.id order_id,
                concat(sp.first_name, ' ', sp.last_name) as customer_name,
                sp.id customer_id,
                pi.quantity as quantity,
                po.status as status,
                'Purchase Order' as type,
                pr.value1 as value1,
                pr.value2 as value2,
                pr.value3 as value3
            FROM sub_products pr
            LEFT JOIN purchase_items pi ON pr.id = pi.purchased_item_id
            LEFT JOIN purchase_orders po ON pi.purchase_order_id = po.id
            LEFT JOIN suppliers sp ON po.supplier_id = sp.id
            WHERE po.status <> 'quote' AND pr.product_id = #{params[:id]}
            )
        ) AS pr
        ORDER BY pr.move_date DESC
      "
      @item_movements = ActiveRecord::Base.connection.exec_query(sql)
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
          product.sku = row[1] unless row[1].blank?
          product.name = row[2] unless row[2].blank?
          product.description = ''
          product.brand = Brand.find_or_create_by(name: row[3].capitalize) unless row[3].blank?
          product.category = Category.find_or_create_by(name: row[4].capitalize) unless row[4].blank?
          product.product_line = ProductLine.find_or_create_by(name: row[5].capitalize) unless row[5].blank?
          product.warehouse = Warehouse.find_or_create_by(name: row[15].capitalize) unless row[15].blank?
          product.reorder_qty = row[6].to_i unless row[6].blank?
          product.open_qty = row[7].to_i unless row[7].blank?
          product.selling_tax = Tax.find_by(name: row[18])
          product.purchase_tax = Tax.find_by(name: row[18])

          purchase_value = 0
          sell_value = 0
          unless row[8].blank?                
            purchase_value = (row[8].strip.chars.first == '$') ? row[8].slice!(1..-1).to_f : row[8].to_f
            product.purchase_price_ex = purchase_value
            product.purchase_price = (product.purchase_tax.nil?) ? purchase_value : purchase_value * (product.purchase_tax.rate + 100) * 0.01
          end

          if row[9].blank? && !row[10].blank?
            product.selling_price = product.purchase_price_ex * (100 + row[10].to_f) * 0.01
            product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
          elsif !row[9].blank?
            sell_value = (row[9].strip.chars.first == '$') ? row[9].slice!(1..-1).to_f : row[9].to_f
            product.selling_price = sell_value
            product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
          end
          product.selling_price_type  = false
          product.purchase_price_type = true
          product.quantity = row[7].to_i unless row[7].blank?
          product.save

          price = (product.prices.nil?) ? nil : product.prices.find_by(name: "Wholesale");
          if price.nil?
            price = product.prices.new(name: "Wholesale")
          end
          price.price_type = 0

          if row[12].blank? && !row[13].blank?
            price.value = product.purchase_price_ex * (100 + row[13].to_f) * 0.01
          elsif !row[12].blank?
            sell_value = (row[12].strip.chars.first == '$') ? row[12].strip.slice!(1..-1).to_f : row[12].to_f
            price.value = sell_value
          end
          price_tax = Tax.find_by(name: row[18])
          price.tax_value = price_tax.rate unless price_tax.nil?
          price.save

          generate_product_sku product if row[1].blank?
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
              product = Product.find_by(barcode: xlsx.cell(line, 'C').to_s.strip)
              if product.nil? 
                product = Product.new
                product.barcode = xlsx.cell(line, 'A').to_s.strip unless xlsx.cell(line, 'A').nil?
                product.sku = xlsx.cell(line, 'B').to_s.strip unless xlsx.cell(line, 'B').nil?
                product.name = xlsx.cell(line, 'C').to_s.strip unless xlsx.cell(line, 'C').nil?
                product.description = ''
                product.brand = Brand.find_or_create_by(name: xlsx.cell(line, 'D').to_s.strip.capitalize) unless xlsx.cell(line, 'D').nil?
                product.category = Category.find_or_create_by(name: xlsx.cell(line, 'E').to_s.strip.capitalize) unless xlsx.cell(line, 'E').nil?
                product.product_line = ProductLine.find_or_create_by(name: xlsx.cell(line, 'F').to_s.strip.capitalize) unless xlsx.cell(line, 'F').nil?
                product.warehouse = Warehouse.find_or_create_by(name: xlsx.cell(line, 'P').to_s.strip.capitalize) unless xlsx.cell(line, 'P').nil?
                product.reorder_qty = xlsx.cell(line, 'G').to_i unless xlsx.cell(line, 'G').nil?
                product.open_qty = xlsx.cell(line, 'H').to_i unless xlsx.cell(line, 'H').nil?
                product.selling_tax = Tax.find_by(name: xlsx.cell(line, 'S'))
                product.purchase_tax = Tax.find_by(name: xlsx.cell(line, 'S'))

                purchase_value = 0
                sell_value = 0
                unless xlsx.cell(line, 'I').nil?                
                  purchase_value = (xlsx.cell(line, 'I').to_s.strip.chars.first == '$') ? xlsx.cell(line, 'I').to_s.strip.slice!(1..-1).to_f : xlsx.cell(line, 'I').to_f
                  product.purchase_price_ex = purchase_value
                  product.purchase_price = (product.purchase_tax.nil?) ? purchase_value : purchase_value * (product.purchase_tax.rate + 100) * 0.01
                end

                if xlsx.cell(line, 'J').nil? && !xlsx.cell(line, 'K').nil?
                  product.selling_price = product.purchase_price_ex * (100 + xlsx.cell(line, 'K').to_f) * 0.01
                  product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
                elsif !xlsx.cell(line, 'J').nil?
                  sell_value = (xlsx.cell(line, 'J').to_s.strip.chars.first == '$') ? xlsx.cell(line, 'J').to_s.strip.slice!(1..-1).to_f : xlsx.cell(line, 'J').to_f
                  product.selling_price = sell_value
                  product.selling_price_ex = (product.selling_tax.nil?) ? product.selling_price : product.selling_price * (100 - product.selling_tax.rate) * 0.01
                end
                product.selling_price_type  = false
                product.purchase_price_type = true
                product.quantity = xlsx.cell(line, 'H').to_i unless xlsx.cell(line, 'H').nil?
                product.save

                price = (product.prices.nil?) ? nil : product.prices.find_by(name: "Wholesale");
                if price.nil?
                  price = product.prices.new(name: "Wholesale")
                end
                price.price_type = 0

                if xlsx.cell(line, 'M').nil? && !xlsx.cell(line, 'N').nil?
                  price.value = product.purchase_price_ex * (100 + xlsx.cell(line, 'N').to_f) * 0.01
                elsif !xlsx.cell(line, 'M').nil?
                  sell_value = (xlsx.cell(line, 'M').to_s.strip.chars.first == '$') ? xlsx.cell(line, 'M').to_s.strip.slice!(1..-1).to_f : xlsx.cell(line, 'M').to_f
                  price.value = sell_value
                end

                price_tax = Tax.find_by(name: xlsx.cell(line, 'S'))
                price.tax_value = price_tax.rate unless price_tax.nil?
                price.save
              end
              
              generate_product_sku product if xlsx.cell(line, 'B').nil?
            end        
          end
        end
      end
    end
    
    def save_product_variant
      index = 1
      params[:variants].each do |variant|
        @product.variants.create(name: variant[1][:name], value: variant[1][:value], order_num: index)
        index += 1
      end
    end

    def save_sub_product
      params[:sub_product].each do |item|
        sub_product = @product.sub_products.create(
          option1: item[1][:option1],
          value1: item[1][:value1],
          option2: item[1][:option2],
          value2: item[1][:value2],
          option3: item[1][:option3],
          value3: item[1][:value3],
          sku: item[1][:sku],
          barcode: item[1][:barcode],
          open_qty: item[1][:open_qty],
          quantity: item[1][:open_qty],
          purchase_price: @product.purchase_price,
          selling_price: (item[1][:selling_price]) ? item[1][:selling_price] : @product.selling_price,
          warehouse_id: @product.warehouse_id,
          reorder_qty: @product.reorder_qty,
          selling_tax_id:  @product.selling_tax_id,
          purchase_tax_id: @product.purchase_tax_id,
          selling_price_ex: @product.selling_price_ex,
          purchase_price_ex: @product.purchase_price_ex,
          selling_price_type: @product.selling_price_type,
          purchase_price_type: @product.purchase_price_type,
          warehouse_id: @product.warehouse_id
          )

        if sub_product.sku.blank?
          sub_product.sku = generate_sub_product_sku sub_product
          sub_product.save          
        end
      end
    end

    def save_single_sub_product
      sub_product = @product.sub_products.create(
        option1: '',
        value1: '',
        option2: '',
        value2: '',
        option3: '',
        value3: '',
        sku: @product.sku,
        barcode: @product.barcode,
        open_qty: @product.open_qty,
        quantity: @product.open_qty,
        purchase_price: @product.purchase_price,
        selling_price: @product.selling_price,
        warehouse_id: @product.warehouse_id,
        reorder_qty: @product.reorder_qty,
        stock_status: @product.stock_status,
        selling_tax_id:  @product.selling_tax_id,
        purchase_tax_id: @product.purchase_tax_id,
        selling_price_ex: @product.selling_price_ex,
        purchase_price_ex: @product.purchase_price_ex,
        selling_price_type: @product.selling_price_type,
        purchase_price_type: @product.purchase_price_type
        )
      if sub_product.sku.blank?
        sub_product.sku = generate_sub_product_sku sub_product
        sub_product.save
      end
    end

    def save_product_unit
      params[:product_unit].each do |index, item|
        unless item[:name].blank? or item[:ratio].blank?
          product_unit = @product.units.create(
            name: item[:name],
            ratio: item[:ratio]
          )
          product_unit.save
        end
      end
    end

    def update_product_units
      params[:product_unit].each do |index, item|
        if item[:id].blank?
          product_unit = @product.units.create(
            name: item[:name],
            ratio: item[:ratio]
          )
          product_unit.save
        else
          unless item[:name].blank? or item[:ratio].blank?
            product_unit = ProductUnit.find(item[:id])
            product_unit.name = item[:name]
            product_unit.ratio = item[:ratio]
            product_unit.save
          end          
        end
      end
    end
end
