class StartControlMasterJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  def perform
    connected = ControlMasterService.start
    status = SystemStatus.for("control_master")
    status.connected = connected
    status.status = connected ? "connected" : "disconnected"
    status.save!

    broadcast_status(status)
  end

  private

  def broadcast_status(status)
    Turbo::StreamsChannel.broadcast_replace_to(
      "system_status",
      target: "control_master_indicator",
      html: ApplicationController.render(
        Dashboard::SystemIndicatorComponent.new(
          key: "control_master",
          label: "Control Master",
          connected: status.connected,
          status: status.status,
          connect_path: connect_control_master_path,
          disconnect_path: disconnect_control_master_path
        ),
        layout: false
      )
    )
  end
end
