class ControlMasterService
  CONTROL_PATH = Rails.root.join("tmp", "dispatch_control_master").to_s

  def self.connected?
    host = Settings.control_master_host.to_s
    return false if host.blank?

    system("ssh", "-O", "check", "-o", "ControlPath=#{CONTROL_PATH}", Shellwords.escape(host), ">/dev/null 2>&1")
  end

  def self.start
    host = Settings.control_master_host.to_s
    return false if host.blank?

    kinit_if_needed
    FileUtils.rm_f(CONTROL_PATH)

    Tempfile.open("ssh_control_master") do |err_file|
      r, w = IO.pipe
      w.puts "1" # Select Duo Push for first hop
      w.puts "1" # Select Duo Push for second hop (ProxyJump)
      w.close

      success = system(
        "ssh", "-fN", "-o", "ControlMaster=yes", "-o", "ControlPath=#{CONTROL_PATH}",
        "-o", "ConnectTimeout=30", Shellwords.escape(host),
        in: r, err: err_file.path
      )
      r.close
      unless success
        Rails.logger.error(
          "[ControlMasterService] ssh failed: #{err_file.read.strip}"
        )
      end
    end

    connected?
  end

  def self.stop
    host = Settings.control_master_host.to_s
    return unless host.present?

    system("ssh", "-O", "exit", "-o", "ControlPath=#{CONTROL_PATH}", Shellwords.escape(host), ">/dev/null 2>&1")
  end

  def self.kinit_if_needed
    if system("klist -s >/dev/null 2>&1")
      Rails.logger.info("[ControlMasterService] Kerberos tickets valid, skipping kinit")
      return
    end

    sunetid = Settings.sunetid.to_s
    unless system("kinit #{Shellwords.escape(sunetid)}@stanford.edu >/dev/null 2>&1")
      Rails.logger.error("[ControlMasterService] kinit failed (exit #{$CHILD_STATUS.exitstatus})")
    end
  end
  private_class_method :kinit_if_needed
end
