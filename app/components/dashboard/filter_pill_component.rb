module Dashboard
  class FilterPillComponent < ViewComponent::Base
    def initialize(options:, selected: nil)
      @options = options
      @selected = selected || options.first
    end

    attr_reader :options, :selected
  end
end
