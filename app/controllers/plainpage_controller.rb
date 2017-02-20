class PlainpageController < ApplicationController
	
  def index
    flash[:success ] = "Success Flash Message: Welcome to GentellelaOnRails"
    #other alternatives are
    # flash[:warn ] = "Israel don't quite like warnings"
    #flash[:danger ] = "Naomi let the dog out!"
  end

  def product_type  	
  end

  def product_list    
    @categories = Category.all
    @brands = Brand.all
    @product_lines = ProductLine.all
  end

  def product_cat
    @categories = Category.all
  end

  def product_line
    @product_lines = ProductLine.all
  end

  def product_brand
    @brands = Brand.all
  end

  def order_list
  end

  def order_new
  end

  def edit_config_company
    set_company_logo 'company.image'
    set_company_config 'company.name'
    set_company_config 'company.trading'
    set_company_config 'company.address'
    set_company_config 'company.phone'
    set_company_config 'company.fax'
    set_company_config 'company.email'
    set_company_config 'company.url'

    if params['company.image']
      tmp = params['company.image'].tempfile    
      destiny_file = File.join('public', 'images', params['company.image'].original_filename)
      FileUtils.move tmp.path, destiny_file
      File.chmod(0777, destiny_file)
    end
    redirect_to config_company_path
  end

  def config_company
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end
  end

  def config_users
    @users = User.all
  end

  def config_tax
  end

  def config_price
  end

  def config_format
  end

  def config_station
  end

  def config_email
  end

  def shipping_method
  end

  # Ajax Request
  def smart_search
    customers = Customer.main_like(params[:key])
    result_customer = []
    customers.each do | elem |
      item = {
        :icon => 'fa-building-o',
        :name => elem.name,
        :phone => elem.phone,
        :email => elem.email,
        :id => elem.id
      }
      result_customer << item
    end
    customer_html = render_to_string :template => 'plainpage/snippet/customer_result', :layout => false, :locals => {customers: result_customer}, formats: :html

    products = Product.lived.main_like(params[:key])
    result_product = []
    products.each do | elem |
      item = {
        :icon => 'fa-cube',
        :name => elem.name,
        :sku => elem.sku,
        :id => elem.id,
        :brand => elem.brand.name,
        :brand_id => elem.brand.id,
        :category => elem.category.name,
        :category_id => elem.category.id,
        :product_line => elem.product_line.name,
        :product_line_id => elem.product_line.id,
        :quantity => elem.stock
      }
      result_product << item
    end    
    product_html = render_to_string :template => 'plainpage/snippet/product_result', :layout => false, :locals => {products: result_product}, formats: :html

    suppliers = Supplier.main_like(params[:key])
    result_supplier = []
    suppliers.each do | elem |
      item = {
        :icon => 'fa-building-o',
        :name => elem.name,
        :phone => elem.phone,
        :email => elem.email,
        :id => elem.id
      }
      result_supplier << item
    end
    supplier_html = render_to_string :template => 'plainpage/snippet/supplier_result', :layout => false, :locals => {suppliers: result_supplier}, formats: :html

    sales_orders = SalesOrder.by_customer_name(params[:key])
    result_salesorder = []
    sales_orders.each do | elem |
      item = {
        :icon => 'fa-file-text-o',
        :company_name => elem.customer.name,
        :order_date => elem.order_date,
        :status => elem.status,
        :token => elem.token,
        :id => elem.id
      }
      result_salesorder << item
    end
    sales_order_html = render_to_string :template => 'plainpage/snippet/sales_order_result', :layout => false, :locals => {sales_orders: result_salesorder}, formats: :html

    users = User.main_like(params[:key])
    result_user = []
    users.each do | elem |
      item = {
        :icon => 'fa-user',
        :name => elem.full_name,
        :phone => elem.phone_number,
        :email => elem.email,
        :id => elem.id
      }
      result_user << item
    end
    user_html = render_to_string :template => 'plainpage/snippet/user_result', :layout => false, :locals => {users: result_user}, formats: :html

    respond_to do |format|
      result = {:result => "OK", 
                :htmls => customer_html + supplier_html + user_html +  product_html + sales_order_html
              }
      format.json {render :json => result}
    end    
  end

  private
  def set_company_config(key)
    setting = Setting.object_by(key)
    setting.conf_type = 1
    setting.value = params[key]
    setting.save    
  end

  def set_company_logo(key)
    setting = Setting.object_by(key)
    setting.conf_type = 1    
    setting.value = params[key].original_filename if params[key]
    setting.save    
  end
end
