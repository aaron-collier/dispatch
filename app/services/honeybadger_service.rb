require "net/http"
require "json"

class HoneybadgerService
  def faults_for_repo(repository)
    project_id = project_id_for(repository)
    return [] unless project_id

    response = get("projects/#{project_id}/faults", limit: Settings.honeybadger_api.max_faults)
    response.fetch("results", []).first(Settings.honeybadger_api.max_faults)
  end

  def deployments_for_repo(repository)
    project_id = project_id_for(repository)
    return [] unless project_id

    response = get("projects/#{project_id}/deploys", limit: Settings.honeybadger_api.max_deploys)
    response.fetch("results", []).first(Settings.honeybadger_api.max_deploys)
  end

  private

  def project_id_for(repository)
    return repository.project_id if repository.project_id.present?

    projects = get("projects").fetch("results", [])
    project  = projects.find { |p| p["name"] == repository.name.delete_prefix("sul-dlss/") }
    return nil unless project

    repository.update!(project_id: project["id"])
    project["id"]
  end

  def get(path, params = {})
    uri = URI("#{Settings.honeybadger_api.url}/#{path}")
    uri.query = URI.encode_www_form(params) unless params.empty?

    request = Net::HTTP::Get.new(uri)
    request.basic_auth(ENV["HONEYBADGER_AUTH_TOKEN"].to_s, "")
    request["Accept"] = "application/json"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
      http.request(request)
    end

    return {} unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error("HoneybadgerService: #{e.message}")
    {}
  end
end
