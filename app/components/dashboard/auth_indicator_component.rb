module Dashboard
  class AuthIndicatorComponent < ViewComponent::Base
    attr_reader :authenticated

    def initialize(authenticated:)
      @authenticated = authenticated
    end

    def status_color
      authenticated ? "var(--dispatch-success)" : "var(--dispatch-danger)"
    end

    def status_text
      authenticated ? "Authenticated" : "Not Authenticated"
    end
  end
end
