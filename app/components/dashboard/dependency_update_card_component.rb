module Dashboard
  class DependencyUpdateCardComponent < ViewComponent::Base
    attr_reader :open_count, :passing, :building, :failing

    def initialize(open_count:, passing:, building:, failing:, all_merged:,
                   merge_all_path: nil, release_all_path: nil)
      @open_count       = open_count
      @passing          = passing
      @building         = building
      @failing          = failing
      @all_merged       = all_merged
      @merge_all_path   = merge_all_path
      @release_all_path = release_all_path
    end

    def sub_line_parts
      [
        { count: passing,  label: "passing", color: "var(--dispatch-success)" },
        { count: building, label: "running", color: "var(--dispatch-warning)" },
        { count: failing,  label: "failing", color: "var(--dispatch-danger)"  }
      ]
    end

    def show_merge_button?
      @merge_all_path.present? && open_count > 0 && open_count == passing
    end

    def show_release_button?
      @release_all_path.present? && open_count == 0 && @all_merged
    end

    def merge_all_path  = @merge_all_path
    def release_all_path = @release_all_path
  end
end
