class AuthController < ApplicationController
  def new
  end

  def callback
    mark_authenticated
    redirect_to root_path
  end

  def create
    mark_authenticated
    redirect_to root_path
  end

  private

  def mark_authenticated
    status = SystemStatus.for("auth")
    status.connected = true
    status.expires_at = Time.current + Settings.auth.ttl_hours.hours
    status.save!
    broadcast_status(true)
  end

  def broadcast_status(authenticated)
    Turbo::StreamsChannel.broadcast_replace_to(
      "system_status",
      target: "auth_indicator",
      html: ApplicationController.render(
        Dashboard::AuthIndicatorComponent.new(authenticated: authenticated),
        layout: false
      )
    )
  end
end
