module Dashboard
  class SidebarComponent < ViewComponent::Base
    NAV_SECTIONS = [
      {
        label: "Overview",
        items: [
          { label: "Dashboard",    icon: "bi-grid-1x2",        path: "/",             active: true },
          { label: "Deployments",  icon: "bi-rocket-takeoff",  path: "/deployments",  active: false },
          { label: "Environments", icon: "bi-layers",          path: "/environments", active: false }
        ]
      },
      {
        label: "Testing",
        items: [
          { label: "Test Suites", icon: "bi-check2-circle", path: "/test-suites", active: false },
          { label: "Flaky Tests", icon: "bi-bug",           path: "/flaky-tests", active: false }
        ]
      },
      {
        label: "Dependencies",
        items: [
          { label: "PR Monitor", icon: "bi-git",          path: "/pr-monitor", active: false },
          { label: "Updates",    icon: "bi-arrow-repeat", path: "/updates",    active: false }
        ]
      },
      {
        label: "Settings",
        items: [
          { label: "Settings", icon: "bi-gear", path: "/settings", active: false }
        ]
      }
    ].freeze

    def initialize(user: UserPresenter.new)
      @user = user
    end

    attr_reader :user

    def nav_sections
      NAV_SECTIONS
    end
  end
end
