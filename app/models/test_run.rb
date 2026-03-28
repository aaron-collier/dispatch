class TestRun < ApplicationRecord
  include AASM

  belongs_to :integration_test

  aasm column: :status do
    state :queuing, initial: true
    state :running
    state :failed
    state :passed

    event :start do
      transitions from: :queuing, to: :running
    end

    event :pass do
      transitions from: :running, to: :passed
    end

    event :fail do
      transitions from: :running, to: :failed
    end
  end
end
