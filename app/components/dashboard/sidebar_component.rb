module Dashboard
  class SidebarComponent < ViewComponent::Base
    NAV_SECTIONS = [
      {
        label: "Overview",
        items: [
          { label: "Dashboard",    icon: "bi-grid-1x2",        path: "/" },
          { label: "Deployments",  icon: "bi-rocket-takeoff",  path: "/deployments" },
          { label: "Environments", icon: "bi-layers",          path: "/environments" }
        ]
      },
      {
        label: "Testing",
        items: [
          { label: "Test Suite", icon: "bi-check2-circle", path: "/integration_tests" },
          { label: "Flaky Tests", icon: "bi-bug",           path: "/flaky-tests" }
        ]
      },
      {
        label: "Dependencies",
        items: [
          { label: "PR Monitor", icon: "bi-git",          path: "/pr-monitor" },
          { label: "Updates",    icon: "bi-arrow-repeat", path: "/updates" }
        ]
      },
      {
        label: "Settings",
        items: [
          { label: "Settings", icon: "bi-gear", path: "/settings" }
        ]
      }
    ].freeze

    def initialize(user: UserPresenter.new, active_path: "/")
      @user = user
      @active_path = active_path
    end

    attr_reader :user

    def nav_sections
      NAV_SECTIONS.map do |section|
        section.merge(
          items: section[:items].map { |item| item.merge(active: item[:path] == @active_path) }
        )
      end
    end
  end
end
