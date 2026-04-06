class DependencyUpdatesFeedPresenter
  DependencyUpdateRow = Struct.new(:repo_name, :pr_url, :pr_state, :release_tag, keyword_init: true)

  GITHUB_BASE = "https://github.com"

  def rows
    Repository.order(:name).map { |repo| row_for(repo) }
  end

  private

  def row_for(repo)
    open_pr = repo.update_pull_requests.status_open.order(updated_at: :desc).first
    if open_pr
      DependencyUpdateRow.new(
        repo_name:   repo.name,
        pr_url:      github_url(repo.name, open_pr.pull_request),
        pr_state:    open_pr.build.to_sym,
        release_tag: repo.release_tag
      )
    else
      recent = repo.update_pull_requests
                   .where.not(status: UpdatePullRequest.statuses[:open])
                   .where(updated_at: 1.week.ago..)
                   .order(updated_at: :desc)
                   .first
      DependencyUpdateRow.new(
        repo_name:   repo.name,
        pr_url:      recent ? github_url(repo.name, recent.pull_request) : nil,
        pr_state:    recent ? :merged : :none,
        release_tag: repo.release_tag
      )
    end
  end

  def github_url(repo_name, pr_number)
    "#{GITHUB_BASE}/#{repo_name}/pull/#{pr_number}"
  end
end
