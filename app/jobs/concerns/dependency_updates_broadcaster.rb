module DependencyUpdatesBroadcaster
  extend ActiveSupport::Concern

  private

  def broadcast_card
    routes = Rails.application.routes.url_helpers
    Turbo::StreamsChannel.broadcast_replace_to(
      "dependency_updates",
      target: "dependency_update_card",
      html: ApplicationController.render(
        Dashboard::DependencyUpdateCardComponent.new(
          open_count:       UpdatePullRequest.status_open.count,
          passing:          UpdatePullRequest.status_open.build_passing.count,
          building:         UpdatePullRequest.status_open.build_building.count,
          failing:          UpdatePullRequest.status_open.build_failing.count,
          all_merged:       all_merged?,
          merge_all_path:   routes.merge_all_dependency_updates_path,
          release_all_path: routes.release_all_dependency_updates_path
        ),
        layout: false
      )
    )
  end

  def broadcast_feed
    Turbo::StreamsChannel.broadcast_replace_to(
      "dependency_updates",
      target: "dependency_update_feed",
      html: ApplicationController.render(
        Dashboard::DependencyUpdateFeedComponent.new(rows: DependencyUpdatesFeedPresenter.new.rows),
        layout: false
      )
    )
  end

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
