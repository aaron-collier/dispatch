class DashboardPresenter
  StatCard   = Struct.new(:label, :value, :delta, :delta_direction, :sparkline_data, keyword_init: true)
  FlakeyTest = Struct.new(:name, :suite, :fail_rate, :last_seen, keyword_init: true)
  Activity   = Struct.new(:icon, :icon_color, :message, :timestamp, :actor, keyword_init: true)
  ChartPoint = Struct.new(:label, :value, keyword_init: true)
  DonutSlice = Struct.new(:label, :value, :color, keyword_init: true)
  DoraMetric = Struct.new(:label, :value, :unit, :tier, :icon, keyword_init: true)

  def stat_cards
    [
      StatCard.new(
        label: "Bugs Healed",
        value: "1,284",
        delta: "+12%",
        delta_direction: :up,
        sparkline_data: [ 42, 55, 48, 70, 65, 80, 91, 88, 102, 110 ]
      ),
      StatCard.new(
        label: "Lines Refactored",
        value: "84,321",
        delta: "+8.3%",
        delta_direction: :up,
        sparkline_data: [ 200, 450, 380, 620, 590, 710, 680, 820, 790, 843 ]
      ),
      StatCard.new(
        label: "Auto-Generated PRs",
        value: "342",
        delta: "-3%",
        delta_direction: :down,
        sparkline_data: [ 30, 35, 28, 40, 38, 42, 36, 39, 34, 34 ]
      )
    ]
  end

  def health_score
    { score: 94, label: "Excellent" }
  end

  def health_segments
    [
      { label: "Passing", value: 847, color: "var(--dispatch-success)" },
      { label: "Flaky",   value: 43,  color: "var(--dispatch-warning)" },
      { label: "Failing", value: 12,  color: "var(--dispatch-danger)"  },
      { label: "Skipped", value: 22,  color: "var(--dispatch-text-muted)" }
    ]
  end

  def flaky_tests
    [
      FlakeyTest.new(name: "UserAuthFlow#login_with_sso",  suite: "auth",         fail_rate: 38, last_seen: "2h ago"),
      FlakeyTest.new(name: "PaymentController#charge",     suite: "payments",     fail_rate: 24, last_seen: "4h ago"),
      FlakeyTest.new(name: "RepoSync#webhook_delivery",    suite: "integrations", fail_rate: 17, last_seen: "6h ago"),
      FlakeyTest.new(name: "DashboardController#index",    suite: "controllers",  fail_rate: 9,  last_seen: "1d ago")
    ]
  end

  def activity_feed
    [
      Activity.new(icon: "bi-git",            icon_color: "var(--dispatch-success)", message: "PR #481 merged to main",           timestamp: "3m ago",  actor: "aaronc"),
      Activity.new(icon: "bi-shield-check",   icon_color: "var(--dispatch-info)",    message: "Security scan passed",             timestamp: "12m ago", actor: "ci-bot"),
      Activity.new(icon: "bi-rocket-takeoff", icon_color: "var(--dispatch-purple)",  message: "Deployed v2.4.1 to production",    timestamp: "1h ago",  actor: "deploy-bot"),
      Activity.new(icon: "bi-bug",            icon_color: "var(--dispatch-danger)",  message: "Regression detected in auth flow", timestamp: "2h ago",  actor: "sentinel"),
      Activity.new(icon: "bi-arrow-repeat",   icon_color: "var(--dispatch-warning)", message: "Auto-refactor PR #483 opened",     timestamp: "3h ago",  actor: "refactor-bot")
    ]
  end

  def line_chart_data
    labels = %w[Oct Nov Dec Jan Feb Mar]
    values = [ 45, 62, 38, 71, 58, 84 ]
    labels.each_with_index.map { |label, i| ChartPoint.new(label: label, value: values[i]) }
  end

  def donut_chart_data
    [
      DonutSlice.new(label: "Passing", value: 847, color: "var(--dispatch-success)"),
      DonutSlice.new(label: "Flaky",   value: 43,  color: "var(--dispatch-warning)"),
      DonutSlice.new(label: "Failing", value: 12,  color: "var(--dispatch-danger)"),
      DonutSlice.new(label: "Skipped", value: 22,  color: "var(--dispatch-text-muted)")
    ]
  end

  def dora_metrics
    [
      DoraMetric.new(label: "Deployment Frequency", value: "4.2", unit: "/ day", tier: :elite, icon: "bi-rocket-takeoff"),
      DoraMetric.new(label: "Lead Time for Changes", value: "18",  unit: "min",  tier: :elite, icon: "bi-clock-history"),
      DoraMetric.new(label: "Change Failure Rate",   value: "1.4", unit: "%",    tier: :high,  icon: "bi-shield-exclamation"),
      DoraMetric.new(label: "MTTR",                  value: "22",  unit: "min",  tier: :elite, icon: "bi-arrow-counterclockwise")
    ]
  end
end
