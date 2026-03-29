class SystemStatus < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :connected, inclusion: { in: [ true, false ] }

  def self.for(name)
    find_or_initialize_by(name: name.to_s)
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def active?
    connected? && !expired?
  end
end
