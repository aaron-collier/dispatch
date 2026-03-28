module Dashboard
  class FilterPillComponent < ViewComponent::Base
    # options: Array of Strings OR Array of {label:, value:} hashes
    # link_param / base_path: when set, render <a> tags for query-param navigation
    # extra_params: Hash of additional query params to include in every link href
    def initialize(options:, selected: nil, link_param: nil, base_path: nil, extra_params: {}, turbo_frame: nil)
      @options      = options
      @link_param   = link_param
      @base_path    = base_path
      @extra_params = extra_params
      @turbo_frame  = turbo_frame
      @selected     = selected || label_for(options.first)
    end

    attr_reader :options, :selected, :link_param, :base_path, :extra_params, :turbo_frame

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
      query = extra_params.merge(link_param => option_value(option))
      "#{base_path}?#{URI.encode_www_form(query)}"
    end

    private

    def label_for(option)
      option.is_a?(Hash) ? option[:label] : option
    end
  end
end
