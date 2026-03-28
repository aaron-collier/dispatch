class DeploymentsPresenter
  PERIODS = {
    "last_week"    => -> { 1.week.ago },
    "last_month"   => -> { 1.month.ago },
    "last_90_days" => -> { 90.days.ago },
    "all_time"     => nil
  }.freeze

  PERIOD_OPTIONS = [
    { label: "Last Month",   value: "last_month" },
    { label: "Last Week",    value: "last_week" },
    { label: "Last 90 Days", value: "last_90_days" },
    { label: "All Time",     value: "all_time" }
  ].freeze

  ENV_OPTIONS = [
    { label: "All",        value: "all" },
    { label: "Production", value: "prod" },
    { label: "Stage",      value: "stage" },
    { label: "QA",         value: "qa" }
  ].freeze

  VALID_ENVS = %w[prod stage qa].freeze

  TableRow     = Struct.new(:name, :env, :count, :last_deployed, keyword_init: true)
  ActivityItem = Struct.new(:icon, :icon_color, :message, :timestamp, :actor, keyword_init: true)

  def initialize(period: "last_month", env: "all")
    @period = PERIODS.key?(period) ? period : "last_month"
    @env    = VALID_ENVS.include?(env) ? env : "all"
  end

  def period_options
    PERIOD_OPTIONS
  end

  def env_options
    ENV_OPTIONS
  end

  def selected_period_label
    PERIOD_OPTIONS.find { |o| o[:value] == @period }&.fetch(:label, "Last Month")
  end

  def selected_env_label
    ENV_OPTIONS.find { |o| o[:value] == @env }&.fetch(:label, "All")
  end

  def table_rows
    scoped = env_scope(period_scope)
    groups = scoped.includes(:repository).group(:repository_id, :environment)

    counts     = groups.count
    last_dates = groups.maximum(:date)

    rows = counts.map do |(repo_id, env), count|
      repo = repository_cache[repo_id]
      next unless repo

      last_date = last_dates[[ repo_id, env ]]
      TableRow.new(
        name:          repo.name.delete_prefix("sul-dlss/"),
        env:           env,
        count:         count,
        last_deployed: last_date ? time_ago(last_date) : "—"
      )
    end.compact

    rows.sort_by { |r| -r.count }
  end

  def activity_feed
    # Load full records (need user column) sorted by date desc, then keep
    # only the most recent deployment per repository across all environments.
    latest_by_repo = Deployment.order(date: :desc)
                               .group_by(&:repository_id)
                               .transform_values(&:first)

    repo_ids = latest_by_repo.keys
    repos    = Repository.where(id: repo_ids).sort_by { |r| r.name.delete_prefix("sul-dlss/") }

    repos.map do |repo|
      d = latest_by_repo[repo.id]
      ActivityItem.new(
        icon:       "bi-rocket-takeoff",
        icon_color: "var(--dispatch-purple)",
        message:    "#{repo.name.delete_prefix("sul-dlss/")} (#{d.environment}, #{d.user})",
        timestamp:  d.date ? time_ago(d.date) : "—",
        actor:      nil
      )
    end
  end

  private

  def period_scope
    cutoff_fn = PERIODS[@period]
    return Deployment.all if cutoff_fn.nil?

    Deployment.where("date >= ?", cutoff_fn.call)
  end

  def env_scope(scope)
    return scope if @env == "all"

    scope.where(environment: Deployment.environments[@env])
  end

  def repository_cache
    @repository_cache ||= Repository.all.index_by(&:id)
  end

  def time_ago(date)
    seconds = (Time.current - date.to_time).round.abs
    return "#{seconds}s ago"               if seconds < 60
    return "#{(seconds / 60).round}m ago"  if seconds < 3600
    return "#{(seconds / 3600).round}h ago" if seconds < 86_400
    days = (seconds / 86_400).round
    return "#{days}d ago"                  if days < 30
    months = (days / 30.0).round
    return "#{months}mo ago"               if months < 12
    "#{(months / 12.0).round}y ago"
  end
end
