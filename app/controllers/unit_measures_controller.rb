class UnitMeasuresController < ApplicationController

  # POST /unit_measures/list
  def list
    if params[:jtSorting]
      @unit_measures = UnitMeasure.all.order(params[:jtSorting])
    else
      @unit_measures = UnitMeasure.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @unit_measures.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end

    result_unit = []
    @unit_measures.each do |item|
      result_unit.push({id: item.id, unit_category_name: item.unit_category.name, name: item.name, ratio: item.ratio, unit_category_id: item.unit_category_id})
    end

    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @unit_measures.count, :Records => result_unit}
      format.json {render :json => result}
    end
  end

  def by_category
    @unit_measures = UnitMeasure.where(:unit_category_id => params[:category_id])
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @unit_measures.count, :Records => @unit_measures}
      format.json {render :json => result}
    end
  end

  # POST /unit_measures/remove
  def remove
    @unit_measure = UnitMeasure.find(params[:id])        
    respond_to do |format|
      if @unit_measure.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@unit_measure.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /unit_measures/change
  def change
    @unit_measure = UnitMeasure.find(params[:id])    
    @unit_measure.name = params[:name]    
    @unit_measure.ratio = params[:ratio]    
    @unit_measure.unit_category_id = params[:unit_category_id]    
    respond_to do |format|
      if @unit_measure.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@unit_measure.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /unit_measures/append
  def append
    @unit_measure = UnitMeasure.new
    @unit_measure.name = params[:name]    
    @unit_measure.ratio = params[:ratio]    
    @unit_measure.unit_category_id = params[:unit_category_id]    
    respond_to do |format|
      if @unit_measure.save
        result = {:Result => "OK", :Record => @unit_measure}
      else
        result = {:Result => "ERROR", :Message =>@unit_measure.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

end
