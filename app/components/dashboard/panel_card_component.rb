module Dashboard
  class PanelCardComponent < ViewComponent::Base
    renders_one :body

    def initialize(title:, filter_options: nil)
      @title          = title
      @filter_options = filter_options
    end

    attr_reader :title, :filter_options
  end
end
