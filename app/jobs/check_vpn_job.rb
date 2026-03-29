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
    # scutil --nc list reports all configured VPN connections and their status.
    # Unlike checking for utun interfaces (which macOS always creates), this
    # correctly returns "(Connected)" only when a VPN session is actually active.
    `scutil --nc list 2>/dev/null`.include?("(Connected)")
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
