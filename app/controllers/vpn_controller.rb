class VpnController < ApplicationController
  def connect
    VpnService.open
    status = SystemStatus.for("vpn")
    connected = VpnService.connected?
    status.update!(connected: connected, status: connected ? "connected" : "disconnected") if status.connected != connected
    render_indicator_update(status.reload)
  end

  private

  def render_indicator_update(status)
    component = Dashboard::SystemIndicatorComponent.new(
      key: "vpn",
      label: "VPN",
      connected: status.connected,
      status: status.status,
      connect_path: connect_vpn_path
    )
    render turbo_stream: turbo_stream.replace(
      "vpn_indicator",
      html: ApplicationController.render(component, layout: false)
    )
  end
end
