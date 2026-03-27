class CheckControlMasterJob < ApplicationJob
  queue_as :default

  def perform
    connected = control_master_connected?
    status = SystemStatus.for("control_master")
    status.connected = connected
    status.save!

    broadcast_status(connected)
  end

  private

  def control_master_connected?
    host = Settings.control_master_host.to_s
    return false if host.blank?

    # ssh -O check exits 0 if a ControlMaster session is open to the host,
    # non-zero otherwise. Both stdout and stderr are suppressed.
    system("ssh -O check #{Shellwords.escape(host)} >/dev/null 2>&1")
  end

  def broadcast_status(connected)
    Turbo::StreamsChannel.broadcast_replace_to(
      "system_status",
      target: "control_master_indicator",
      html: ApplicationController.render(
        Dashboard::SystemIndicatorComponent.new(key: "control_master", label: "Control Master", connected: connected),
        layout: false
      )
    )
  end
end
