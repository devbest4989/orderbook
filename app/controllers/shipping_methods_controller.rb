class ShippingMethodsController < ApplicationController

  # POST /shipping_methods/list
  def list
    if params[:jtSorting]
      @shipping_methods = ShippingMethod.all.order(params[:jtSorting])
    else
      @shipping_methods = ShippingMethod.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @shipping_methods.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @shipping_methods.count, :Records => @shipping_methods}
      format.json {render :json => result}
    end
  end

  # POST /shipping_methods/remove
  def remove
    @shipping_method = ShippingMethod.find(params[:id])        
    respond_to do |format|
      if @shipping_method.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@shipping_method.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /shipping_methods/change
  def change
    @shipping_method = ShippingMethod.find(params[:id])    
    @shipping_method.rate = params[:rate]    
    @shipping_method.description = params[:description]    
    @shipping_method.name = params[:name]    
    respond_to do |format|
      if @shipping_method.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@shipping_method.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /shipping_methods/append
  def append
    @shipping_method = ShippingMethod.new
    @shipping_method.name = params[:name]    
    respond_to do |format|
      if @shipping_method.save
        result = {:Result => "OK", :Record => @shipping_method}
      else
        result = {:Result => "ERROR", :Message =>@shipping_method.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

end
