class PaymentTermsController < ApplicationController

  # POST /payment_terms/list
  def list
    if params[:jtSorting]
      @payment_terms = PaymentTerm.all.order(params[:jtSorting])
    else
      @payment_terms = PaymentTerm.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @payment_terms.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @payment_terms.count, :Records => @payment_terms}
      format.json {render :json => result}
    end
  end

  # POST /payment_terms/remove
  def remove
    @payment_term = PaymentTerm.find(params[:id])        
    respond_to do |format|
      if @payment_term.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@payment_term.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /payment_terms/change
  def change
    @payment_term = PaymentTerm.find(params[:id])    
    @payment_term.days = params[:days]    
    @payment_term.term_type = params[:term_type]    
    @payment_term.name = params[:name]    
    respond_to do |format|
      if @payment_term.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@payment_term.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /payment_terms/append
  def append
    @payment_term = PaymentTerm.new
    @payment_term.days = params[:days]    
    @payment_term.term_type = params[:term_type]    
    @payment_term.name = params[:name]    
    respond_to do |format|
      if @payment_term.save
        result = {:Result => "OK", :Record => @payment_term}
      else
        result = {:Result => "ERROR", :Message =>@payment_term.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

end
