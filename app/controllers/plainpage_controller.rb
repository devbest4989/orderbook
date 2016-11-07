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
end
