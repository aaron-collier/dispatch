module Dashboard
  class SystemIndicatorComponent < ViewComponent::Base
    attr_reader :key, :label, :connected

    def initialize(key:, label:, connected:)
      @key = key
      @label = label
      @connected = connected
    end

    def status_color
      connected ? "var(--dispatch-success)" : "var(--dispatch-danger)"
    end

    def status_text
      connected ? "Connected" : "Disconnected"
    end
  end
end
