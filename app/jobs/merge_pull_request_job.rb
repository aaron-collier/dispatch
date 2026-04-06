class MergePullRequestJob < ApplicationJob
  include DependencyUpdatesBroadcaster

  queue_as :default

  def perform(repository_id, pull_request_number)
    repo = Repository.find(repository_id)
    octokit_client.create_pull_request_review(pr[:repo], pr[:number], body: 'Approved by automated merge script', event: 'APPROVE')
    octokit_client.merge_pull_request(repo.name, pull_request_number, "Merged by automated merge script")
    UpdatePullRequest.find_by!(pull_request: pull_request_number).update!(status: :merged)
    broadcast_card
    broadcast_feed
  rescue Octokit::MethodNotAllowed, Octokit::UnprocessableEntity => e
    Rails.logger.warn("MergePullRequestJob: #{repo.name}##{pull_request_number}: #{e.message}")
  end

  private

  def octokit_client
    token = Settings.github_auth_token.presence || ENV["GH_ACCESS_TOKEN"].presence
    token ? Octokit::Client.new(access_token: token) : Octokit::Client.new
  end
end
