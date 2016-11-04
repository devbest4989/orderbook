class ProductLinesController < ApplicationController
  before_action :set_product_line, only: [:show, :edit, :update, :destroy]

  # POST /product_lines/list_option
  def list_option
    @product_lines = ProductLine.all
    respond_to do |format|
      product_line_options = []
      product_line_options << {:Value => "", :DisplayText => "Select Product Line"}
      @product_lines.each do |item| 
        product_line_options << {:Value => item.id, :DisplayText => item.name}
      end
      result = {:Result => "OK", :Options => product_line_options}
      format.json {render :json => result}
    end
  end

  # POST /product_lines/list
  def list
    if params[:jtSorting]
      @product_lines = ProductLine.all.order(params[:jtSorting])
    else
      @product_lines = ProductLine.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @product_lines.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @product_lines.count, :Records => @product_lines}
      format.json {render :json => result}
    end
  end

  # POST /product_lines/remove
  def remove
    @product_line = ProductLine.find(params[:id])        
    respond_to do |format|
      if @product_line.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@product_line.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /product_lines/change
  def change
    @product_line = ProductLine.find(params[:id])    
    @product_line.name = params[:name]
    
    respond_to do |format|
      if @product_line.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@product_line.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /product_lines/append
  def append
    @product_line = ProductLine.new
    @product_line.name = params[:name]
    
    respond_to do |format|
      if @product_line.save
        result = {:Result => "OK", :Record => @product_line}
      else
        result = {:Result => "ERROR", :Message =>@product_line.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # GET /product_lines
  # GET /product_lines.json
  def index
    @product_lines = ProductLine.all
  end

  # GET /product_lines/1
  # GET /product_lines/1.json
  def show
  end

  # GET /product_lines/new
  def new
    @product_line = ProductLine.new
  end

  # GET /product_lines/1/edit
  def edit
  end

  # POST /product_lines
  # POST /product_lines.json
  def create
    @product_line = ProductLine.new(product_line_params)

    respond_to do |format|
      if @product_line.save
        format.html { redirect_to @product_line, notice: 'Product line was successfully created.' }
        format.json { render :show, status: :created, location: @product_line }
      else
        format.html { render :new }
        format.json { render json: @product_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /product_lines/1
  # PATCH/PUT /product_lines/1.json
  def update
    respond_to do |format|
      if @product_line.update(product_line_params)
        format.html { redirect_to @product_line, notice: 'Product line was successfully updated.' }
        format.json { render :show, status: :ok, location: @product_line }
      else
        format.html { render :edit }
        format.json { render json: @product_line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /product_lines/1
  # DELETE /product_lines/1.json
  def destroy
    @product_line.destroy
    respond_to do |format|
      format.html { redirect_to product_lines_url, notice: 'Product line was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_line
      @product_line = ProductLine.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_line_params
      params.require(:product_line).permit(:name)
    end
end
