require "net/http"

class RefreshRepositoriesJob < ApplicationJob
  queue_as :default

  def perform
    yaml = fetch_yaml
    return unless yaml

    data = YAML.safe_load(yaml, permitted_classes: [], aliases: true)
    projects = data.fetch("projects", [])

    merge_only_list = Array(Settings.merge_only_repositories).map(&:to_s)

    projects.each do |attrs|
      name = attrs["repo"]
      repo = Repository.for(name)
      repo.cocina_models_update = attrs.fetch("cocina_level2", false)
      repo.merge_only           = merge_only_list.include?(name)
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
