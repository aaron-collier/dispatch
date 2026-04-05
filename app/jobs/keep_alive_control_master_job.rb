class KeepAliveControlMasterJob < ApplicationJob
  include Rails.application.routes.url_helpers

  queue_as :default

  def perform
    status = SystemStatus.find_by(name: "control_master")
    return unless status&.status == "connected"

    unless ControlMasterService.connected?
      status.update!(connected: false, status: "disconnected")
      broadcast_status(status)
    end
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
