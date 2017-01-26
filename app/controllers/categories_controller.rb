class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :edit, :update, :destroy]

  # POST /categories/list_option
  def list_option
    @categories = Category.all
    respond_to do |format|
      category_options = []
      category_options << {:Value => "", :DisplayText => "Select Category"}
      @categories.each do |cat| 
        category_options << {:Value => cat.id, :DisplayText => cat.name}
      end
      result = {:Result => "OK", :Options => category_options}
      format.json {render :json => result}
    end
  end

  # POST /categories/list
  def list
    if params[:jtSorting]
      @categories = Category.all.order(params[:jtSorting])
    else
      @categories = Category.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @categories.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @categories.count, :Records => @categories}
      format.json {render :json => result}
    end
  end

  # POST /categories/remove
  def remove
    @category = Category.find(params[:id])        
    respond_to do |format|
      if @category.destroy
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@category.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /categories/change
  def change
    @category = Category.find(params[:id])    
    @category.name = params[:name].capitalize    
    respond_to do |format|
      if @category.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@category.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # POST /categories/append
  def append
    @category = Category.new
    @category.name = params[:name].capitalize
    respond_to do |format|
      if @category.save
        result = {:Result => "OK", :Record => @category}
      else
        result = {:Result => "ERROR", :Message =>@category.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/1
  # GET /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)

    respond_to do |format|
      if @category.save
        format.html { redirect_to @category, notice: 'Category was successfully created.' }
        format.json { render :show, status: :created, location: @category }
      else
        format.html { render :new }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to @category, notice: 'Category was successfully updated.' }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'Category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name)
    end
end
