module Dashboard
  class DoraCardComponent < ViewComponent::Base
    TIER_COLORS = {
      elite:  "var(--dispatch-dora-elite)",
      high:   "var(--dispatch-dora-high)",
      medium: "var(--dispatch-dora-mid)",
      low:    "var(--dispatch-dora-low)"
    }.freeze

    def initialize(label:, value:, unit:, tier:, icon:)
      @label = label
      @value = value
      @unit  = unit
      @tier  = tier
      @icon  = icon
    end

    attr_reader :label, :value, :unit, :tier, :icon

    def tier_label
      tier.to_s.capitalize
    end

    def tier_css_modifier
      tier.to_s
    end

    def tier_color
      TIER_COLORS[tier] || TIER_COLORS[:low]
    end
  end
end
