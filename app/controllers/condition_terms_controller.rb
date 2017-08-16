class ConditionTermsController < ApplicationController

  # POST /condition_terms/list
  def list
    if params[:jtSorting]
      @condition_terms = ConditionTerm.all.order(params[:jtSorting])
    else
      @condition_terms = ConditionTerm.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @condition_terms.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @condition_terms.count, :Records => @condition_terms}
      format.json {render :json => result}
    end
  end

  # POST /condition_terms/remove
  def remove
    @condition_term = ConditionTerm.find(params[:id])        
    respond_to do |format|
      if @condition_term.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@condition_term.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /condition_terms/change
  def change
    @condition_term = ConditionTerm.find(params[:id])    
    @condition_term.title = params[:title]    
    @condition_term.description = params[:description]        
    respond_to do |format|
      if @condition_term.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@condition_term.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /condition_terms/append
  def append
    @condition_term = ConditionTerm.new
    @condition_term.title = params[:title]    
    @condition_term.description = params[:description]        
    respond_to do |format|
      if @condition_term.save
        result = {:Result => "OK", :Record => @condition_term}
      else
        result = {:Result => "ERROR", :Message =>@condition_term.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

end
