class CheckVpnJob < ApplicationJob
  queue_as :default

  def perform
    connected = vpn_connected?
    status = SystemStatus.for("vpn")
    status.connected = connected
    status.save!

    broadcast_status(connected)
  end

  private

  def vpn_connected?
    # On macOS, VPN clients (Cisco AnyConnect, GlobalProtect, WireGuard, etc.)
    # create utun* network interfaces. Presence of any utun interface indicates
    # an active VPN connection.
    interfaces = `ifconfig 2>/dev/null`
    interfaces.match?(/^utun\d+:/m)
  end

  def broadcast_status(connected)
    Turbo::StreamsChannel.broadcast_replace_to(
      "system_status",
      target: "vpn_indicator",
      html: ApplicationController.render(
        Dashboard::SystemIndicatorComponent.new(key: "vpn", label: "VPN", connected: connected),
        layout: false
      )
    )
  end
end
