require "rails_helper"

RSpec.describe ControlMasterService do
  let(:host) { "bastion.example.com" }

  before do
    allow(Settings).to receive(:control_master_host).and_return(host)
    allow(Settings).to receive(:sunetid).and_return("jdoe")
  end

  describe ".connected?" do
    context "when the control master socket responds" do
      before { allow(described_class).to receive(:system).and_return(true) }

      it { expect(described_class.connected?).to be(true) }
    end

    context "when no socket is active" do
      before { allow(described_class).to receive(:system).and_return(false) }

      it { expect(described_class.connected?).to be(false) }
    end

    context "when control_master_host is blank" do
      before { allow(Settings).to receive(:control_master_host).and_return("") }

      it "returns false without calling ssh" do
        expect(described_class).not_to receive(:system)
        expect(described_class.connected?).to be(false)
      end
    end
  end

  describe ".start" do
    context "when control_master_host is blank" do
      before { allow(Settings).to receive(:control_master_host).and_return("") }

      it "returns false without running any commands" do
        expect(described_class).not_to receive(:system)
        expect(described_class.start).to be(false)
      end
    end

    context "when Kerberos tickets are already valid" do
      before do
        allow(described_class).to receive(:system).with(/klist -s/).and_return(true)
        allow(described_class).to receive(:system).with("ssh", "-fN", any_args).and_return(true)
        allow(described_class).to receive(:connected?).and_return(true)
      end

      it "skips kinit" do
        expect(described_class).not_to receive(:system).with(/kinit/)
        described_class.start
      end

      it "establishes the control master" do
        expect(described_class).to receive(:system).twice # .with("ssh", "-fN", "-o", "ControlMaster=yes", "-o", "ControlPath=.dispatch/tmp/dispatch_control_master", "-o", "ConnectTimeout=30", "bastion.example.com", {err: "/var/folders/ld/b_hg3g4563z0l7njfj07j8ww0000gp/T/ssh_control_master20260404-28962-nhnkjv", in: #<IO:fd 11>})
        described_class.start
      end

      it "returns true when connected" do
        expect(described_class.start).to be(true)
      end
    end

    context "when Kerberos tickets are missing" do
      before do
        allow(described_class).to receive(:system).with(/klist -s/).and_return(false)
        allow(described_class).to receive(:system).with(/kinit/).and_return(true)
        allow(described_class).to receive(:system) # .with(/ssh -fN/, anything).and_return(true)
        allow(described_class).to receive(:connected?).and_return(true)
      end

      it "runs kinit before establishing the connection" do
        expect(described_class).to receive(:system).with(/klist -s/).and_return(false).ordered
        expect(described_class).to receive(:system).with(/kinit jdoe@stanford\.edu/).and_return(true).ordered
        expect(described_class).to receive(:system).ordered # ssh
        described_class.start
      end
    end

    context "when ssh fails to establish the connection" do
      before do
        allow(described_class).to receive(:system).with(/klist -s/).and_return(true)
        allow(described_class).to receive(:system).with("ssh", "-fN", any_args).and_return(false)
        allow(described_class).to receive(:connected?).and_return(false)
      end

      it "returns false" do
        expect(described_class.start).to be(false)
      end

      it "logs the error" do
        expect(Rails.logger).to receive(:error).with(/ssh failed/)
        described_class.start
      end
    end
  end

  describe ".stop" do
    context "when control_master_host is blank" do
      before { allow(Settings).to receive(:control_master_host).and_return("") }

      it "does nothing" do
        expect(described_class).not_to receive(:system)
        described_class.stop
      end
    end

    context "when a host is configured" do
      before { allow(described_class).to receive(:system).and_return(true) }

      it "sends the exit signal to the control master" do
        described_class.stop
        expect(described_class).to have_received(:system).with(
          "ssh", "-O", "exit",
          "-o", a_string_matching(/ControlPath=.*tmp\/dispatch_control_master/),
          "bastion.example.com",
          ">/dev/null 2>&1"
        )
      end
    end
  end
end
