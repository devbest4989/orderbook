class BrandsController < ApplicationController
  before_action :set_brand, only: [:show, :edit, :update, :destroy]

  # POST /brands/list_option
  def list_option
    @brands = Brand.all
    respond_to do |format|
      brand_options = []
      brand_options << {:Value => "", :DisplayText => "Select Brand"}
      @brands.each do |item| 
        brand_options << {:Value => item.id, :DisplayText => item.name}
      end
      result = {:Result => "OK", :Options => brand_options}
      format.json {render :json => result}
    end
  end

  # POST /brands/list
  def list
    if params[:jtSorting]
      @brands = Brand.all.order(params[:jtSorting])
    else
      @brands = Brand.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @brands.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @brands.count, :Records => @brands}
      format.json {render :json => result}
    end
  end

  # POST /brands/remove
  def remove
    @brand = Brand.find(params[:id])    
    
    respond_to do |format|
      if @brand.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@brands.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /brands/change
  def change
    @brand = Brand.find(params[:id])    
    @brand.name = params[:name].capitalize    
    respond_to do |format|
      if @brand.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@brands.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /brands/append
  def append
    @brand = Brand.new
    @brand.name = params[:name].capitalize
    respond_to do |format|
      if @brand.save
        result = {:Result => "OK", :Record => @brand}
      else
        result = {:Result => "ERROR", :Message =>@brands.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # GET /brands
  # GET /brands.json
  def index
    @brands = Brand.all
  end

  # GET /brands/1
  # GET /brands/1.json
  def show
  end

  # GET /brands/new
  def new
    @brand = Brand.new
  end

  # GET /brands/1/edit
  def edit
  end

  # POST /brands
  # POST /brands.json
  def create
    @brand = Brand.new(brand_params)

    respond_to do |format|
      if @brand.save
        format.html { redirect_to @brand, notice: 'Brand was successfully created.' }
        format.json { render :show, status: :created, loitemion: @brand }
      else
        format.html { render :new }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /brands/1
  # PATCH/PUT /brands/1.json
  def update
    respond_to do |format|
      if @brand.update(brand_params)
        format.html { redirect_to @brand, notice: 'Brand was successfully updated.' }
        format.json { render :show, status: :ok, loitemion: @brand }
      else
        format.html { render :edit }
        format.json { render json: @brand.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brands/1
  # DELETE /brands/1.json
  def destroy
    @brand.destroy
    respond_to do |format|
      format.html { redirect_to brands_url, notice: 'Brand was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_brand
      @brand = Brand.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def brand_params
      params.require(:brand).permit(:name)
    end
end
