class CreateReleaseJob < ApplicationJob
  include DependencyUpdatesBroadcaster

  queue_as :default

  def perform(repository_id)
    repo = Repository.find(repository_id)
    tag = "rel-#{Date.current.strftime('%Y-%m-%d')}"
    message = "created by #{Settings.name} using dispatch"
    octokit_client.create_release(repo.name, tag, name: tag, body: message)
    repo.update!(release_tag: tag)
    broadcast_card
    broadcast_feed
  rescue Octokit::UnprocessableEntity => e
    Rails.logger.warn("CreateReleaseJob: #{repo.name}: #{e.message}")
  end

  private

  def octokit_client
    token = Settings.github_auth_token.presence || ENV["GH_ACCESS_TOKEN"].presence
    token ? Octokit::Client.new(access_token: token) : Octokit::Client.new
  end
end
