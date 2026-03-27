class Repository < ApplicationRecord
  serialize :exclude_envs,      coder: JSON
  serialize :non_standard_envs, coder: JSON

  has_many :update_pull_requests, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.for(name)
    find_or_initialize_by(name: name.to_s)
  end
end
