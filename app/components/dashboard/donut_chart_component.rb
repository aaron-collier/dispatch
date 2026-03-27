module Dashboard
  class DonutChartComponent < ViewComponent::Base
    RADIUS       = 44.0
    STROKE_WIDTH = 28.0
    CIRCUMFERENCE = (2 * Math::PI * RADIUS).freeze

    def initialize(slices:)
      @slices = slices
    end

    attr_reader :slices

    def total
      slices.sum(&:value).to_f
    end

    def segments
      offset = 0.0
      slices.map do |slice|
        pct       = total.positive? ? slice.value.to_f / total : 0.0
        dash      = (pct * CIRCUMFERENCE).round(2)
        gap       = CIRCUMFERENCE.round(2)
        seg = {
          label:      slice.label,
          color:      slice.color,
          value:      slice.value,
          dasharray:  "#{dash} #{gap}",
          dashoffset: (-offset).round(2)
        }
        offset += dash
        seg
      end
    end
  end
end
