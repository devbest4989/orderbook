class UnitCategoriesController < ApplicationController

  # POST /unit_categories/list
  def list
    if params[:jtSorting]
      @unit_categories = UnitCategory.all.order(params[:jtSorting])
    else
      @unit_categories = UnitCategory.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @unit_categories.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @unit_categories.count, :Records => @unit_categories}
      format.json {render :json => result}
    end
  end

  def list_option
    @unit_categories = UnitCategory.all
    unit_options = []
    @unit_categories.each do |item|
      unit_options.push({DisplayText: item.name, Value: item.id})
    end
    respond_to do |format|
      result = {:Result => "OK", :Options => unit_options}
      format.json {render :json => result}
    end    
  end

  # POST /unit_categories/remove
  def remove
    @unit_category = UnitCategory.find(params[:id])        
    respond_to do |format|
      if @unit_category.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@unit_category.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /unit_categories/change
  def change
    @unit_category = UnitCategory.find(params[:id])    
    @unit_category.name = params[:name]    
    respond_to do |format|
      if @unit_category.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@unit_category.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /unit_categories/append
  def append
    @unit_category = UnitCategory.new
    @unit_category.name = params[:name]    
    respond_to do |format|
      if @unit_category.save
        result = {:Result => "OK", :Record => @unit_category}
      else
        result = {:Result => "ERROR", :Message =>@unit_category.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

end
