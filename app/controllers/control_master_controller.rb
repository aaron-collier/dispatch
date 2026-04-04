class ControlMasterController < ApplicationController
  def connect
    status = SystemStatus.for("control_master")
    status.update!(connected: false, status: "connecting")
    StartControlMasterJob.perform_later
    render_indicator_update(status)
  end

  def disconnect
    status = SystemStatus.for("control_master")
    status.update!(connected: true, status: "disconnecting")
    StopControlMasterJob.perform_later
    render_indicator_update(status)
  end

  private

  def render_indicator_update(status)
    component = Dashboard::SystemIndicatorComponent.new(
      key: "control_master",
      label: "Control Master",
      connected: status.connected,
      status: status.status,
      connect_path: connect_control_master_path,
      disconnect_path: disconnect_control_master_path
    )
    render turbo_stream: turbo_stream.replace(
      "control_master_indicator",
      html: ApplicationController.render(component, layout: false)
    )
  end
end
