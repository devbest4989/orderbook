class WarehousesController < ApplicationController

  # POST /warehouses/list
  def list
    if params[:jtSorting]
      @warehouses = Warehouse.all.order(params[:jtSorting])
    else
      @warehouses = Warehouse.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @warehouses.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @warehouses.count, :Records => @warehouses}
      format.json {render :json => result}
    end
  end

  # POST /warehouses/remove
  def remove
    @warehouse = Warehouse.find(params[:id])        
    respond_to do |format|
      if @warehouse.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@warehouse.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /warehouses/change
  def change
    @warehouse = Warehouse.find(params[:id])    
    @warehouse.name = params[:name].capitalize
    respond_to do |format|
      if @warehouse.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@warehouse.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /warehouses/append
  def append
    @warehouse = Warehouse.new
    @warehouse.name = params[:name].capitalize
    respond_to do |format|
      if @warehouse.save
        result = {:Result => "OK", :Record => @warehouse}
      else
        result = {:Result => "ERROR", :Message =>@warehouse.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

end
