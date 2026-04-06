class DependencyUpdatesController < ApplicationController
  def merge_all
    UpdatePullRequest.status_open.build_passing.each do |pr|
      MergePullRequestJob.perform_later(pr.repository_id, pr.pull_request)
    end
    render turbo_stream: turbo_stream.replace(
      "dependency_update_card",
      html: ApplicationController.render(card_component(merge_all_path: nil, release_all_path: nil), layout: false)
    )
  end

  def release_all
    Repository.joins(:update_pull_requests)
              .where(update_pull_requests: {
                status: UpdatePullRequest.statuses[:merged],
                updated_at: 1.day.ago..
              })
              .where(release_tag: nil)
              .distinct
              .each { |repo| CreateReleaseJob.perform_later(repo.id) }
    render turbo_stream: turbo_stream.replace(
      "dependency_update_card",
      html: ApplicationController.render(card_component(merge_all_path: nil, release_all_path: nil), layout: false)
    )
  end

  private

  def card_component(merge_all_path:, release_all_path:)
    Dashboard::DependencyUpdateCardComponent.new(
      open_count:       UpdatePullRequest.status_open.count,
      passing:          UpdatePullRequest.status_open.build_passing.count,
      building:         UpdatePullRequest.status_open.build_building.count,
      failing:          UpdatePullRequest.status_open.build_failing.count,
      all_merged:       false,
      merge_all_path:   merge_all_path,
      release_all_path: release_all_path
    )
  end
end
