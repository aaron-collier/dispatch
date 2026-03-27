class DashboardController < ApplicationController
  def index
    @presenter = DashboardPresenter.new
    @user = UserPresenter.new
    @system_statuses = SystemStatus.all.index_by(&:name)
    CheckVpnJob.perform_later unless @system_statuses.key?("vpn")
    CheckControlMasterJob.perform_later unless @system_statuses.key?("control_master")
  end
end
