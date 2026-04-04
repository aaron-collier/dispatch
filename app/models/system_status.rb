class SystemStatus < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :connected, inclusion: { in: [ true, false ] }

  def self.for(name)
    find_or_initialize_by(name: name.to_s)
  end
end
