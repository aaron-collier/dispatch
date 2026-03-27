module Dashboard
  class LineChartComponent < ViewComponent::Base
    VIEWBOX_WIDTH  = 800.0
    VIEWBOX_HEIGHT = 180.0
    AXIS_HEIGHT    = 30.0
    PADDING_X      = 16.0
    CANVAS_HEIGHT  = VIEWBOX_HEIGHT - AXIS_HEIGHT

    def initialize(data:, color: "var(--dispatch-line-chart)")
      @data  = data
      @color = color
    end

    attr_reader :data, :color

    def gradient_id
      "line-gradient-#{object_id}"
    end

    def path_points
      return [] if data.empty?

      values = data.map(&:value).map(&:to_f)
      min    = values.min
      max    = values.max
      range  = (max - min).nonzero? || 1.0
      w      = VIEWBOX_WIDTH - PADDING_X * 2

      data.each_with_index.map do |point, i|
        x = (i.to_f / (data.length - 1)) * w + PADDING_X
        y = CANVAS_HEIGHT - ((point.value.to_f - min) / range) * (CANVAS_HEIGHT - PADDING_X * 2) - PADDING_X
        [ x.round(2), y.round(2) ]
      end
    end

    def path_d
      return "" if path_points.empty?

      pts = path_points
      first = pts.first
      rest  = pts.drop(1)

      result = "M #{first[0]},#{first[1]}"
      rest.each_with_index do |pt, i|
        prev = pts[i]
        cpx  = ((prev[0] + pt[0]) / 2).round(2)
        result += " C #{cpx},#{prev[1]} #{cpx},#{pt[1]} #{pt[0]},#{pt[1]}"
      end
      result
    end

    def fill_d
      return "" if path_points.empty?

      pts   = path_points
      last  = pts.last
      first = pts.first
      "#{path_d} L #{last[0]},#{CANVAS_HEIGHT} L #{first[0]},#{CANVAS_HEIGHT} Z"
    end
  end
end
