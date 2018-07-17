class PreviewController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception  

  layout 'invoice_preview'
  def invoice
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end

    profile_info = Setting.station
    @standard_setting = {}
    profile_info.each do |info|
      @standard_setting[info.key] = info.value
    end

    @invoice = Invoice.find_by(preview_token: params[:token])
  end

  def bill
    profile_info = Setting.company_profile
    @company_profiles = {}
    profile_info.each do |info|
      @company_profiles[info.key] = info.value
    end

    @bill = Bill.find_by(preview_token: params[:token])
  end
  
end
