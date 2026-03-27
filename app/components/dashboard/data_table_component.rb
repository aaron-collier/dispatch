module Dashboard
  class DataTableComponent < ViewComponent::Base
    def initialize(rows:)
      @rows = rows
    end

    attr_reader :rows
  end
end
