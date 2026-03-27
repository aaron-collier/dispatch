class FetchDependencyUpdatesJob < ApplicationJob
  queue_as :default

  def perform
    client = octokit_client

    Repository.find_each do |repo|
      sync_pull_requests(client, repo)
    end

    broadcast_card
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
    sha = pr.head.sha
    check_runs = client.check_runs_for_ref(repo_name, sha)[:check_runs]

    return :building if check_runs.any? { |r| r.status == "in_progress" }
    return :failing  if check_runs.any? { |r| r.conclusion == "failure" }

    :passing
  rescue Octokit::NotFound, Octokit::Forbidden
    :passing
  end

  def broadcast_card
    Turbo::StreamsChannel.broadcast_replace_to(
      "dependency_updates",
      target: "dependency_update_card",
      html: ApplicationController.render(
        Dashboard::DependencyUpdateCardComponent.new(
          open_count: UpdatePullRequest.status_open.count,
          passing:    UpdatePullRequest.status_open.build_passing.count,
          building:   UpdatePullRequest.status_open.build_building.count,
          failing:    UpdatePullRequest.status_open.build_failing.count
        ),
        layout: false
      )
    )
  end
end
