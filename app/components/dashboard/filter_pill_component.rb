module Dashboard
  class FilterPillComponent < ViewComponent::Base
    # options: Array of Strings OR Array of {label:, value:} hashes
    # link_param / base_path: when set, render <a> tags for query-param navigation
    def initialize(options:, selected: nil, link_param: nil, base_path: nil)
      @options    = options
      @link_param = link_param
      @base_path  = base_path
      @selected   = selected || label_for(options.first)
    end

    attr_reader :options, :selected, :link_param, :base_path

    def link_mode?
      link_param.present?
    end

    def option_label(option)
      option.is_a?(Hash) ? option[:label] : option
    end

    def option_value(option)
      option.is_a?(Hash) ? option[:value] : option
    end

    def option_href(option)
      "#{base_path}?#{link_param}=#{option_value(option)}"
    end

    private

    def label_for(option)
      option.is_a?(Hash) ? option[:label] : option
    end
  end
end
