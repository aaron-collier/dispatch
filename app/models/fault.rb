class Fault < ApplicationRecord
  belongs_to :repository

  enum :environment, { prod: 0, stage: 1, qa: 2 }

  validates :revision,       presence: true
  validates :date,           presence: true
  validates :title,          presence: true
  validates :honeybadger_id, presence: true, uniqueness: true
end
