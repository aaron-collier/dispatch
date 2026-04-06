class SetupIntegrationTestSuiteJob < ApplicationJob
  queue_as :default

  REPO_URL        = "https://github.com/sul-dlss/infrastructure-integration-test".freeze
  REPO_PATH       = Rails.root.join("tmp/infrastructure-integration-test").freeze
  SETTINGS_SOURCE = Rails.root.join("config/settings/stage.local.yml").freeze
  SETTINGS_DEST   = REPO_PATH.join("config/settings/stage.local.yml").freeze

  def perform
    FileUtils.rm_rf(REPO_PATH)
    system("git clone --branch main --depth 1 #{REPO_URL} #{REPO_PATH}")
    FileUtils.mkdir_p(REPO_PATH.join(".bundle"))
    FileUtils.mkdir_p(SETTINGS_DEST.dirname)
    FileUtils.cp(SETTINGS_SOURCE, SETTINGS_DEST)
    bundle_env = {
      "BUNDLE_GEMFILE"    => REPO_PATH.join("Gemfile").to_s,
      "BUNDLE_APP_CONFIG" => REPO_PATH.join(".bundle").to_s
    }
    system(bundle_env, "bundle install", chdir: REPO_PATH.to_s)

    Dir.glob(REPO_PATH.join("spec/features/*_spec.rb")).each do |path|
      name = File.basename(path, "_spec.rb")
      test = IntegrationTest.find_or_create_by!(name: name)
      test_run = test.test_runs.create!(status: "queuing")
      IntegrationTestRunnerJob.perform_later(test_run.id)
    end
  end
end
