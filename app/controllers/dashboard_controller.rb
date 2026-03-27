class DashboardController < ApplicationController
  def index
    @presenter = DashboardPresenter.new
    @user = UserPresenter.new
    @system_statuses = SystemStatus.all.index_by(&:name)
  end
end
