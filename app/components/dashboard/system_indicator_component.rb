module Dashboard
  class SystemIndicatorComponent < ViewComponent::Base
    COLORS = {
      "connected" => "var(--dispatch-success)",
      "disconnected" => "var(--dispatch-danger)",
      "connecting" => "var(--dispatch-warning)",
      "disconnecting" => "var(--dispatch-warning)"
    }.freeze

    TEXTS = {
      "connected" => "Connected",
      "disconnected" => "Disconnected",
      "connecting" => "Connecting...",
      "disconnecting" => "Disconnecting..."
    }.freeze

    attr_reader :key, :label, :connected, :connect_path, :disconnect_path

    def initialize(key:, label:, connected:, status: nil, connect_path: nil, disconnect_path: nil)
      @key = key
      @label = label
      @connected = connected
      @status = status
      @connect_path = connect_path
      @disconnect_path = disconnect_path
    end

    def resolved_status
      @status.presence || (connected ? "connected" : "disconnected")
    end

    def status_color
      COLORS[resolved_status]
    end

    def status_text
      TEXTS[resolved_status]
    end
  end
end
