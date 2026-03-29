class CheckAuthJob < ApplicationJob
  queue_as :default

  def perform
    status = SystemStatus.for("auth")
    return unless status.persisted? && status.expired?

    status.connected = false
    status.save!

    broadcast_status(false)
  end

  private

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
