class TaxesController < ApplicationController

  # POST /taxes/list
  def list
    if params[:jtSorting]
      @taxes = Tax.all.order(params[:jtSorting])
    else
      @taxes = Tax.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @taxes.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @taxes.count, :Records => @taxes}
      format.json {render :json => result}
    end
  end

  # POST /taxes/remove
  def remove
    @tax = Tax.find(params[:id])        
    respond_to do |format|
      if @tax.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@tax.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /taxes/change
  def change
    @tax = Tax.find(params[:id])    
    @tax.rate = params[:rate]    
    @tax.description = params[:description]    
    @tax.name = params[:name]    
    respond_to do |format|
      if @tax.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@tax.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /taxes/append
  def append
    @tax = Tax.new
    @tax.rate = params[:rate]    
    @tax.description = params[:description]    
    @tax.name = params[:name]    
    respond_to do |format|
      if @tax.save
        result = {:Result => "OK", :Record => @tax}
      else
        result = {:Result => "ERROR", :Message =>@tax.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

end
