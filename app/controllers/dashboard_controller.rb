class DashboardController < ApplicationController
  def index
    @presenter = DashboardPresenter.new
    @stats     = TestRunStatsPresenter.new(period: params[:stability_period])
    @user = UserPresenter.new
    @system_statuses = SystemStatus.all.index_by(&:name)
    CheckVpnJob.perform_later unless @system_statuses.key?("vpn")
    CheckControlMasterJob.perform_later unless @system_statuses.key?("control_master")
    CheckAuthJob.perform_later if @system_statuses["auth"]&.expired?
    RefreshRepositoriesJob.perform_later if Repository.none?

    @dependency_card = {
      open_count: UpdatePullRequest.status_open.count,
      passing:    UpdatePullRequest.status_open.build_passing.count,
      building:   UpdatePullRequest.status_open.build_building.count,
      failing:    UpdatePullRequest.status_open.build_failing.count
    }
  end
end
