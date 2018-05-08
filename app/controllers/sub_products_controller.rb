class SubProductsController < ApplicationController
  # GET /sub_products/1/edit
  def new
    @sub_product = SubProduct.new
  end

  def create
    @sub_product = SubProduct.new(sub_product_params)
    ori_sub_product = SubProduct.where(value1: @sub_product.value1, value2: @sub_product.value2, value3: @sub_product.value3, product_id: @sub_product.product_id)
    @sub_product.warehouse = Warehouse.find_or_create_by(name: params[:warehouse_name].capitalize)    
    respond_to do |format|
      if ori_sub_product.blank?
        if @sub_product.save
          @sub_product.product.referesh_variants
          save_sub_product_prices        
          @sub_product.sku = generate_sub_product_sku @sub_product
          @sub_product.save
          format.html { redirect_to edit_sub_product_path(@sub_product), notice: 'Sub Product was successfully created.' }
          format.json { render :show, status: :created, location: @sub_product }
        else
          format.html { render :new }
          format.json { render json: @sub_product.errors, status: :unprocessable_entity }
        end
      else
          flash[:alert] = "The variant already exists. Please change at least one option value."
          format.html { render :new }
          format.json { render json: @sub_product.errors, status: :unprocessable_entity }        
      end
    end    
  end

  def edit
    set_sub_product
    get_sub_product_list
  end

  def update
    set_sub_product

    @sub_product.warehouse = Warehouse.find_or_create_by(name: params[:warehouse_name].capitalize)    

    respond_to do |format|
      if @sub_product.update(sub_product_params)
        @sub_product.product.referesh_variants
        save_sub_product_prices

        format.html { redirect_to edit_sub_product_path(@sub_product), notice: 'Sub Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @sub_product }
      else
        get_sub_product_list
        format.html { render :edit }
        format.json { render json: @sub_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def action
    case params[:action_name]
    when 'status'
      set_invert_status
      redirect_to edit_sub_product_path(@sub_product)
    when 'clone'
      set_clone_sub_product
      render 'new'
    else
      set_sub_product
      redirect_to edit_sub_product_path(@sub_product)
    end
  end

  def destroy
    @sub_product = SubProduct.find(params[:id])
    product = @sub_product.product
    if product.sub_products.length > 1
      @sub_product.destroy
    end
    product.referesh_variants
    redirect_to product_path(product, tab: 'variant')
  end

  def list_by_id
    if params[:id]
      @sub_product = SubProduct.select('sku, id, selling_price_ex, selling_tax_id, product_id').includes(:selling_tax).includes(:prices).find(params[:id])      
    end

    respond_to do |format|
      price = @sub_product.prices.where("LOWER(name) = ?", params[:price_name].downcase).first
      price_value = (price.nil?) ? 'nil' : price.price_tax_exclude
      format.json {render :json => {product: @sub_product, 
                                    tax: @sub_product.selling_tax, 
                                    price: price_value,
                                    units: @sub_product.product.units}
                                  }
    end
  end

  def list_purchase_by_id
    if params[:id]
      @sub_product = SubProduct.select('sku, id, purchase_price_ex, purchase_tax_id, product_id').includes(:purchase_tax).find(params[:id])
    end

    respond_to do |format|
      format.json {render :json => {product: @sub_product, 
                                    units: @sub_product.product.units,
                                    tax: @sub_product.purchase_tax}
                  }
    end
  end

  private
    def set_sub_product
      @sub_product = SubProduct.find(params[:id])
    end

    def get_sub_product_list
      @sub_product_list = @sub_product.product.sub_products      
    end

    def sub_product_params
      params.require(:sub_product).permit(:option1, :value1, :option2, :value2, :option3, :value3, :sku, :barcode, :selling_price, :purchase_price, :image,
                                      :selling_price_ex, :purchase_price_ex, :selling_tax_id, :purchase_tax_id, :selling_price_type, :purchase_price_type,
                                      :reorder_qty, :open_qty, :product_id)
    end

    def save_sub_product_prices
      Price.where(product_id: @sub_product.id).destroy_all
      unless params[:sub_product][:prices_attributes].nil? 
        params[:sub_product][:prices_attributes].each do |index, item| 
          price = @sub_product.prices.new(name: item[:name], value: item[:value], price_type: @sub_product.selling_price_type, product_id: @sub_product.product.id)
          price.save
        end        
      end
    end

    def set_invert_status
      @sub_product = SubProduct.find(params[:id])
      @sub_product.status = !@sub_product.status
      @sub_product.save
    end

    def set_clone_sub_product
      old_product = SubProduct.find(params[:id])
      @sub_product = old_product.dup
      @sub_product.sku = ''
      @sub_product.barcode = ''
      #@sub_product.save

      old_product.prices.each do |item|
        new_price = @sub_product.prices.new(product_id: @sub_product.product_id, name: item.name, price_type: item.price_type, value: item.value, sub_product_id: @sub_product.id)
      end
    end

    def generate_sub_product_sku elem
      sku_string = ""

      sku_string += elem.product.category.name[0].upcase unless elem.product.category.nil?
      sku_string += elem.product.brand.name[0].upcase unless elem.product.brand.nil?

      name_array = elem.product.name.split(' ')
      name_array.each do |item|
        sku_string += item[0].upcase if %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z).include? (item[0].upcase)
      end

      sku_string += "-" + elem.value1.strip.upcase.first(5) unless elem.value1.blank?
      sku_string += "-" + elem.value2.strip.upcase.first(5) unless elem.value1.blank?
      sku_string += "-" + elem.value3.strip.upcase.first(5) unless elem.value1.blank?

      return sku_string + elem.id.to_s        
    end

end
