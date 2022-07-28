class ApplicationController < ActionController::Base
  before_action :authenticate_customer!
  before_action :set_tenant

  def after_sign_in_path_for(resource)
    root_path
  end

  def set_tenant
    return unless current_customer
    ActsAsTenant.current_tenant = current_customer
  end
end
