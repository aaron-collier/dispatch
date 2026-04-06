require "open3"

class IntegrationTestRunnerJob < ApplicationJob
  queue_as :default

  REPO_PATH = Rails.root.join("tmp/infrastructure-integration-test").freeze

  def perform(test_run_id)
    test_run = TestRun.find(test_run_id)
    test     = test_run.integration_test

    test_run.start!
    broadcast(test_run)

    unless Dir.exist?(REPO_PATH)
      test_run.update!(output: "Test directory not found. Run the full suite first.")
      test_run.fail!
      broadcast(test_run)
      return
    end

    env = {
      "BUNDLE_GEMFILE"         => REPO_PATH.join("Gemfile").to_s,
      "BUNDLE_APP_CONFIG"      => REPO_PATH.join(".bundle").to_s,
      "SETTINGS__SUNET__ID"    => Settings.sunetid.to_s,
      "SETTINGS__SUNET__PASSWORD" => Settings.sunet_password.to_s
    }
    output, status = Open3.capture2e(
      env,
      "bundle exec rspec spec/features/#{test.name}_spec.rb",
      chdir: REPO_PATH.to_s
    )
    success = status.success?

    test_run.update!(output: output)
    success ? test_run.pass! : test_run.fail!
    broadcast(test_run)
  rescue StandardError => e
    if test_run
      test_run.update!(output: "Job error: #{e.message}") rescue nil
      test_run.fail! if test_run.may_fail?
      broadcast(test_run) rescue nil
    end
    raise
  end

  private

  def broadcast(test_run)
    Turbo::StreamsChannel.broadcast_replace_to(
      "integration_tests",
      target: "integration_tests_table",
      html: ApplicationController.render(
        Dashboard::DataTableComponent.new(rows: TestRunStatsPresenter.new.test_rows),
        layout: false
      )
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      "integration_tests",
      target: "test_run_#{test_run.id}",
      html: ApplicationController.render(
        partial: "integration_tests/test_run_row",
        locals:  { test_run: test_run }
      )
    )
  end
end
