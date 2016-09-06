class SettingsController < ApplicationController
  before_filter :admin_only
  def index
    #@setting = Order.new new_order_params
    #@order.save  
    @setting = Settings.first
  end
  def update
    setting = Settings.first
    setting.site_name = params["setting"]["site_name"]
    setting.site_logo = params["setting"]["site_logo"] if  params["setting"]["site_logo"]
    setting.order_logo_width = params["setting"]["order_logo_width"]
    setting.order_logo_height = params["setting"]["order_logo_height"]
    setting.save
    redirect_to settings_path
  end
  private
  def admin_only
    unless current_user.admin?
      redirect_to :back, :alert => "Access denied."
    end
  end
end
