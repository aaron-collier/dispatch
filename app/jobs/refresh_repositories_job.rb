require "net/http"

class RefreshRepositoriesJob < ApplicationJob
  queue_as :default

  def perform
    yaml = fetch_yaml
    return unless yaml

    data = YAML.safe_load(yaml, permitted_classes: [], aliases: true)
    repos = data.fetch("repositories", [])

    merge_only_list = Array(Settings.merge_only_repositories).map(&:to_s)

    repos.each do |attrs|
      repo = Repository.for(attrs["name"])
      repo.cocina_models_update = attrs.fetch("cocina_models_update", false)
      repo.exclude_envs         = attrs["exclude_envs"].to_a
      repo.non_standard_envs    = attrs["non_standard_envs"].to_a
      repo.skip_audit           = attrs.fetch("skip_audit", false)
      repo.merge_only           = merge_only_list.include?(attrs["name"].to_s)
      repo.last_updated         = Date.current
      repo.save!
    end

    FetchDependencyUpdatesJob.perform_later
  end

  private

  def fetch_yaml
    uri = URI.parse(Settings.repository_source.to_s)
    Net::HTTP.get(uri)
  rescue StandardError => e
    Rails.logger.error("RefreshRepositoriesJob: failed to fetch YAML: #{e.message}")
    nil
  end
end
