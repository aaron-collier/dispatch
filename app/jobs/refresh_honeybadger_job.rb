class RefreshHoneybadgerJob < ApplicationJob
  queue_as :default

  ENVIRONMENT_MAP = {
    "production" => "prod",
    "staging"    => "stage",
    "qa"         => "qa"
  }.freeze

  def perform
    service = HoneybadgerService.new

    Repository.find_each do |repo|
      sync_deployments(service, repo)
      sync_faults(service, repo)
    end
  end

  private

  def sync_deployments(service, repo)
    service.deployments_for_repo(repo).each do |data|
      env = map_environment(data["environment"])
      next unless env

      Deployment.find_or_create_by!(
        repository: repo,
        revision:   data["revision"],
        environment: env
      ) do |d|
        d.date = data["created_at"]
        d.user = data["local_username"].to_s
      end
    end
  rescue StandardError => e
    Rails.logger.error("RefreshHoneybadgerJob deployments #{repo.name}: #{e.message}")
  end

  def sync_faults(service, repo)
    service.faults_for_repo(repo).each do |data|
      existing = Fault.find_by(honeybadger_id: data["id"])

      if data["resolved"]
        existing&.destroy
        next
      end

      next if existing

      env = map_environment(data["environment"])
      next unless env

      Fault.create!(
        repository:     repo,
        honeybadger_id: data["id"],
        title:          data["message"].to_s,
        environment:    env,
        revision:       data.fetch("revision", "unknown"),
        date:           data["last_notice_at"]
      )
    end
  rescue StandardError => e
    Rails.logger.error("RefreshHoneybadgerJob faults #{repo.name}: #{e.message}")
  end

  def map_environment(env_string)
    ENVIRONMENT_MAP[env_string.to_s.downcase]
  end
end
