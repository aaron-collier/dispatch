module IntegrationTests
  class TestTableComponent < ViewComponent::Base
    # rows: Array of DashboardPresenter::IntegrationTestRow
    # tests: Hash of name => IntegrationTest (for generating show links)
    def initialize(rows:, tests:)
      @rows  = rows
      @tests = tests
    end

    attr_reader :rows, :tests
  end
end
