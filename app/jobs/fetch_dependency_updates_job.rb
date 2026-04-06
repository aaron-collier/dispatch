class FetchDependencyUpdatesJob < ApplicationJob
  include DependencyUpdatesBroadcaster

  queue_as :default

  def perform
    client = octokit_client

    Repository.find_each do |repo|
      sync_pull_requests(client, repo)
    end

    broadcast_card
    broadcast_feed
  end

  private

  def octokit_client
    token = Settings.github_auth_token.presence || ENV["GH_ACCESS_TOKEN"].presence
    token ? Octokit::Client.new(access_token: token) : Octokit::Client.new
  end

  def sync_pull_requests(client, repo)
    prs = client.pull_requests(repo.name, state: "open")
    dependency_prs = prs.select { |pr| pr.head.ref == Settings.update_branch.to_s }
    current_pr_numbers = dependency_prs.map(&:number)

    dependency_prs.each do |pr|
      record = UpdatePullRequest.find_or_initialize_by(pull_request: pr.number)
      record.repository = repo
      record.status     = :open
      record.build      = determine_build_status(client, repo.name, pr)
      record.save!
    end

    UpdatePullRequest.where(repository: repo)
                     .status_open
                     .where.not(pull_request: current_pr_numbers)
                     .update_all(status: UpdatePullRequest.statuses[:closed])
  rescue Octokit::NotFound, Octokit::Forbidden => e
    Rails.logger.warn("FetchDependencyUpdatesJob: #{repo.name}: #{e.message}")
  end

  def determine_build_status(client, repo_name, pr)
    # sha = pr.head.sha
    # check_runs = client.check_runs_for_ref(repo_name, sha)[:check_runs]

    # debugger if repo_name == 'sul_pub'

    statuses = client.combined_status(repo_name, pr.head.sha)

    return :passing if statuses.state == "success" || statuses.total_count.zero?
    return :building if statuses.state == "pending"
    # return :building if check_runs.any? { |r| %w[in_progress queued waiting].include?(r.status) }
    # return :failing  if check_runs.any? { |r| %w[failure cancelled timed_out action_required startup_failure].include?(r.conclusion) }

    :failing
  rescue Octokit::NotFound, Octokit::Forbidden
    :passing
  end
end
