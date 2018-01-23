class ProductVariantsController < ApplicationController
  # POST
  def remove_value
    @product_variant = ProductVariant.find(params[:id])
    product = @product_variant.product
    unless @product_variant.value.split(',').length == 1
      if @product_variant.order_num == 1
        SubProduct.where(value1: params[:tag]).delete_all
      elsif @product_variant.order_num == 2
        SubProduct.where(value2: params[:tag]).delete_all
      else
        SubProduct.where(value3: params[:tag]).delete_all
      end
      @product_variant.value = params[:value]
      @product_variant.save
    end
    respond_to do |format|
      result = {:result => "OK", :url => product_path(product, tab: 'variant') }
      format.json {render :json => result}
    end
  end

end
