class VpnService
  def self.connected?
    # On macOS, VPN clients (Cisco AnyConnect, GlobalProtect, WireGuard, etc.)
    # create utun* network interfaces. Presence of any utun interface indicates
    # an active VPN connection.
    interfaces = `ifconfig 2>/dev/null`
    interfaces.match?(/^utun\d+:/m)
  end

  def self.open
    system("open", "-a", "Cisco Secure Client")
  end
end
