module Dashboard
  class StatCardComponent < ViewComponent::Base
    CANVAS_WIDTH  = 80.0
    CANVAS_HEIGHT = 40.0
    MARGIN        = 4.0

    def initialize(label:, value:, delta:, delta_direction:, sparkline_data: [])
      @label            = label
      @value            = value
      @delta            = delta
      @delta_direction  = delta_direction
      @sparkline_data   = sparkline_data
    end

    attr_reader :label, :value, :delta, :delta_direction, :sparkline_data

    def trend_color
      delta_direction == :up ? "var(--dispatch-success)" : "var(--dispatch-danger)"
    end

    def trend_icon
      delta_direction == :up ? "↗" : "↘"
    end

    def sparkline_points
      return "" if sparkline_data.empty?

      values = sparkline_data.map(&:to_f)
      min    = values.min
      max    = values.max
      range  = (max - min).nonzero? || 1.0
      w      = CANVAS_WIDTH - MARGIN * 2
      h      = CANVAS_HEIGHT - MARGIN * 2

      values.each_with_index.map do |v, i|
        x = (i.to_f / (values.length - 1)) * w + MARGIN
        y = CANVAS_HEIGHT - MARGIN - ((v - min) / range) * h
        "#{x.round(2)},#{y.round(2)}"
      end.join(" ")
    end

    def gradient_id
      "spark-gradient-#{object_id}"
    end
  end
end
