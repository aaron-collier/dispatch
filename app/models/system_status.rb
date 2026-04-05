class SystemStatus < ApplicationRecord
  STATUSES = %w[disconnected connecting connected disconnecting].freeze

  validates :name, presence: true, uniqueness: true
  validates :connected, inclusion: { in: [ true, false ] }
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  def self.for(name)
    find_or_initialize_by(name: name.to_s)
  end
end
