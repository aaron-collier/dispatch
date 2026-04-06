class IntegrationTestsController < ApplicationController
  def index
    @stats = TestRunStatsPresenter.new(period: params[:period] || "all_time", period_option_set: :index)
    @user = UserPresenter.new
  end

  def show
    @integration_test = IntegrationTest.find(params[:id])
    @test_runs = @integration_test.test_runs.order(created_at: :desc)
    @user = UserPresenter.new
  end

  def run
    if params[:id]
      integration_test = IntegrationTest.find(params[:id])
      test_run = integration_test.test_runs.create!(status: "queuing")
      IntegrationTestRunnerJob.perform_later(test_run.id)
      redirect_to integration_test_path(integration_test)
    else
      SetupIntegrationTestSuiteJob.perform_later
      render turbo_stream: turbo_stream.replace(
        "run-tests-btn",
        html: "<span id=\"run-tests-btn\" style=\"font-size: 0.6875rem; font-weight: 600; letter-spacing: 0.04em; color: var(--dispatch-warning);\">SETTING UP...</span>".html_safe
      )
    end
  end
end
