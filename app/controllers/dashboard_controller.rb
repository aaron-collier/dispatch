class DashboardController < ApplicationController
  def index
    @presenter = DashboardPresenter.new
    @stats     = TestRunStatsPresenter.new(period: params[:stability_period])
    @user = UserPresenter.new
    @system_statuses = SystemStatus.all.index_by(&:name)
    KeepAliveVpnJob.perform_later
    RefreshRepositoriesJob.perform_later if Repository.none?

    @dependency_card = {
      open_count: UpdatePullRequest.status_open.count,
      passing:    UpdatePullRequest.status_open.build_passing.count,
      building:   UpdatePullRequest.status_open.build_building.count,
      failing:    UpdatePullRequest.status_open.build_failing.count,
      all_merged: all_merged?
    }
    @dependency_updates_feed = DependencyUpdatesFeedPresenter.new.rows
  end

  private

  def all_merged?
    UpdatePullRequest.status_open.none? &&
      Repository.joins(:update_pull_requests)
                .where(update_pull_requests: {
                  status: UpdatePullRequest.statuses[:merged],
                  updated_at: 1.day.ago..
                })
                .where(release_tag: nil)
                .exists?
  end
end
