module Dashboard
  class DependencyUpdateCardComponent < ViewComponent::Base
    attr_reader :open_count, :passing, :building, :failing

    def initialize(open_count:, passing:, building:, failing:)
      @open_count = open_count
      @passing    = passing
      @building   = building
      @failing    = failing
    end

    def sub_line_parts
      [
        { count: passing,  label: "passing", color: "var(--dispatch-success)" },
        { count: building, label: "running", color: "var(--dispatch-warning)" },
        { count: failing,  label: "failing", color: "var(--dispatch-danger)"  }
      ]
    end
  end
end
