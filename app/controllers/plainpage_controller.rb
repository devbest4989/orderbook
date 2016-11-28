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

    tmp = params['company.image'].tempfile
    destiny_file = File.join('public', 'images', params['company.image'].original_filename)
    FileUtils.move tmp.path, destiny_file

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
    setting.value = params[key].original_filename
    setting.save    
  end
end
