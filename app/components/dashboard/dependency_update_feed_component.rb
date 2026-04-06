module Dashboard
  class DependencyUpdateFeedComponent < ViewComponent::Base
    GREY = "var(--dispatch-text-muted)".freeze

    LIGHT_COLORS = {
      passing:  [ "var(--dispatch-dora-elite)", GREY, GREY, GREY ],
      building: [ GREY, "var(--dispatch-dora-mid)", GREY, GREY ],
      failing:  [ GREY, GREY, "var(--dispatch-dora-low)", GREY ],
      merged:   [ GREY, GREY, GREY, "var(--dispatch-purple-light)" ],
      none:     [ GREY, GREY, GREY, GREY ]
    }.freeze

    ICON_COLORS = {
      passing:  "var(--dispatch-dora-elite)",
      building: "var(--dispatch-dora-mid)",
      failing:  "var(--dispatch-dora-low)",
      merged:   "var(--dispatch-purple-light)",
      none:     GREY
    }.freeze

    def initialize(rows:)
      @rows = rows
    end

    attr_reader :rows

    def light_colors_for(pr_state)
      LIGHT_COLORS.fetch(pr_state, LIGHT_COLORS[:none])
    end

    def icon_color_for(pr_state)
      ICON_COLORS.fetch(pr_state, GREY)
    end

    def short_name(repo_name)
      repo_name.split("/").last
    end
  end
end
