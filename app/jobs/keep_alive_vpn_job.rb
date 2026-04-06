class KeepAliveVpnJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  def perform
    connected = VpnService.connected?
    status = SystemStatus.for("vpn")

    return if status.connected == connected

    status.update!(connected: connected, status: connected ? "connected" : "disconnected")
    broadcast_status(status)
  end

  private

  def broadcast_status(status)
    Turbo::StreamsChannel.broadcast_replace_to(
      "system_status",
      target: "vpn_indicator",
      html: ApplicationController.render(
        Dashboard::SystemIndicatorComponent.new(
          key: "vpn",
          label: "VPN",
          connected: status.connected,
          status: status.status,
          connect_path: connect_vpn_path
        ),
        layout: false
      )
    )
  end
end
