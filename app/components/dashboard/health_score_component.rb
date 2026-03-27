module Dashboard
  class HealthScoreComponent < ViewComponent::Base
    def initialize(score:, label:, segments:)
      @score    = score
      @label    = label
      @segments = segments
    end

    attr_reader :score, :label, :segments

    def total
      segments.sum { |s| s[:value] }
    end

    def segment_flex(segment)
      pct = total.positive? ? (segment[:value].to_f / total * 100).round(2) : 0
      "flex-basis: #{pct}%"
    end
  end
end
