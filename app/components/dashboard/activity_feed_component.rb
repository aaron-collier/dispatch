module Dashboard
  class ActivityFeedComponent < ViewComponent::Base
    def initialize(activities:)
      @activities = activities
    end

    attr_reader :activities
  end
end
