class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # POST /users/list
  def list
    if params[:jtSorting]
      @users = User.all.order(params[:jtSorting])
    else
      @users = User.all
    end
    
    if params[:jtStartIndex] && params[:jtPageSize]
      @users.paginate(page: params[:jtStartIndex].to_i / params[:jtPageSize].to_i + 1, per_page: params[:jtPageSize].to_i )
    end
    respond_to do |format|
      result = {:Result => "OK", :TotalRecordCount => @users.count, :Records => @users}
      format.json {render :json => result}
    end
  end

  # POST /users/change
  def change
    @user = User.find(params[:id])    
    @user.role = params[:role]    
    respond_to do |format|
      if @user.save
        result = {:Result => "OK"}
      else
        result = {:Result => "ERROR", :Message =>@user.errors.full_messages}
      end
      format.json {render :json => result}
    end
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/
  def update_info
    @user = User.find(current_user.id)
    if @user.update(user_params_info)
      sign_in @user, :bypass => true
      redirect_to edit_user_path(current_user.id), flash: {last_action: 'update_info', result: 'success'}
    else
      redirect_to edit_user_path(current_user.id), flash: {last_action: 'update_info', result: 'failed'}
    end
  end

  # PATCH/PUT /users/
  def update_avatar
    @user = User.find(current_user.id)
    if @user.update(user_params_avatar)
      sign_in @user, :bypass => true
      redirect_to edit_user_path(current_user.id), flash: {last_action: 'update_avatar', result: 'success'}
    else
      redirect_to edit_user_path(current_user.id), flash: {last_action: 'update_avatar', result: 'failed'}
    end
  rescue => ex
    redirect_to edit_user_path(current_user.id), flash: {last_action: 'update_avatar', result: 'failed', message: 'Uploading avatar is failed.'}
  end

  # PATCH/PUT /users/
  def update_password
    @user = User.find(current_user.id)
    if @user.update_with_password(user_params_password)
      sign_in @user, :bypass => true
      redirect_to edit_user_path(current_user.id), flash: {last_action: 'update_password', result: 'success'}
    else
      redirect_to edit_user_path(current_user.id), flash: {last_action: 'update_password', result: 'failed'}
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(current_user.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {})
    end

    def user_params_password
      params.require(:user).permit(:password, :password_confirmation, :current_password)      
    end

    def user_params_info
      params.require(:user).permit(:first_name, :last_name, :phone_number, :role)      
    end

    def user_params_avatar
      params.require(:user).permit(:avatar)      
    end
end
