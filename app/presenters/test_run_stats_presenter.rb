class TestRunStatsPresenter
  PERIODS = {
    "all_time"     => nil,
    "today"        => -> { Date.current.beginning_of_day },
    "last_week"    => -> { 1.week.ago },
    "last_month"   => -> { 1.month.ago },
    "last_90_days" => -> { 90.days.ago }
  }.freeze

  PERIOD_OPTIONS = [
    { label: "Last Month",   value: "last_month" },
    { label: "Last Week",    value: "last_week" },
    { label: "Last 90 Days", value: "last_90_days" }
  ].freeze

  INDEX_PERIOD_OPTIONS = [
    { label: "All Time",   value: "all_time" },
    { label: "Today",      value: "today" },
    { label: "Last Week",  value: "last_week" },
    { label: "Last Month", value: "last_month" }
  ].freeze

  # Per-test summary aggregated over the period.
  # classification: :passing (only passes), :flaky (mixed), :failing (only failures)
  # fail_rate: (failed_count / total_count * 100).round(1)
  TestStat = Struct.new(:classification, :passed_count, :failed_count, :last_run_at, keyword_init: true) do
    def total_count = passed_count + failed_count
    def fail_rate   = total_count.positive? ? (failed_count.to_f / total_count * 100).round(1) : 0.0
  end

  def initialize(period: "last_month", period_option_set: :dashboard)
    @period_option_set = period_option_set
    @period = PERIODS.key?(period) ? period : default_period
  end

  def period_options
    @period_option_set == :index ? INDEX_PERIOD_OPTIONS : PERIOD_OPTIONS
  end

  def selected_period_label
    period_options.find { |o| o[:value] == @period }&.fetch(:label) || period_options.first[:label]
  end

  # { score: Integer (0-100), label: String }
  def health_score
    return { score: 0, label: "No Data" } if total_tested.zero?

    score = (passing_count.to_f / total_tested * 100).round
    { score: score, label: score_label(score) }
  end

  # Three segments: Passing, Flaky, Failing (Skipped removed)
  def health_segments
    [
      { label: "Passing", value: passing_count, color: "var(--dispatch-success)" },
      { label: "Flaky",   value: flaky_count,   color: "var(--dispatch-warning)" },
      { label: "Failing", value: failing_count, color: "var(--dispatch-danger)"  }
    ]
  end

  # Returns DashboardPresenter::IntegrationTestRow objects for the data table.
  def test_rows
    latest_runs = TestRun
      .where(id: TestRun.group(:integration_test_id).select("MAX(id)"))
      .index_by(&:integration_test_id)

    IntegrationTest.order(:name).map do |t|
      stat   = per_test_stats[t.id]
      latest = latest_runs[t.id]
      DashboardPresenter::IntegrationTestRow.new(
        id:        t.id,
        name:      t.name,
        status:    latest&.status,
        fail_rate: stat&.fail_rate,
        last_run:  stat&.last_run_at ? time_ago(stat.last_run_at) : nil
      )
    end
  end

  private

  def passing_count = per_test_stats.count { |_, s| s.classification == :passing }
  def flaky_count   = per_test_stats.count { |_, s| s.classification == :flaky   }
  def failing_count = per_test_stats.count { |_, s| s.classification == :failing }
  def total_tested  = per_test_stats.size

  # Returns Hash<integration_test_id, TestStat>
  def per_test_stats
    @per_test_stats ||= begin
      # Count passed/failed runs per test in one query
      counts = period_scope
               .where(status: %w[passed failed])
               .group(:integration_test_id, :status)
               .count

      # Latest completed run timestamp per test
      last_runs = period_scope
                  .where(status: %w[passed failed])
                  .group(:integration_test_id)
                  .maximum(:created_at)

      by_test = Hash.new { |h, k| h[k] = { passed: 0, failed: 0 } }
      counts.each do |(test_id, status), count|
        by_test[test_id][status.to_sym] += count
      end

      by_test.each_with_object({}) do |(test_id, c), result|
        classification = if c[:passed] > 0 && c[:failed] == 0
                           :passing
        elsif c[:passed] > 0 && c[:failed] > 0
                           :flaky
        else
                           :failing
        end

        result[test_id] = TestStat.new(
          classification: classification,
          passed_count:   c[:passed],
          failed_count:   c[:failed],
          last_run_at:    last_runs[test_id]
        )
      end
    end
  end

  def period_scope
    cutoff_fn = PERIODS[@period]
    return TestRun.all if cutoff_fn.nil?

    TestRun.where("created_at >= ?", cutoff_fn.call)
  end

  def default_period
    @period_option_set == :index ? "all_time" : "last_month"
  end

  def score_label(score)
    case score
    when 90..100 then "Excellent"
    when 75..89  then "Good"
    when 50..74  then "Fair"
    else              "Poor"
    end
  end

  def time_ago(time)
    seconds = (Time.current - time).round.abs
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
