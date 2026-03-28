class Deployment < ApplicationRecord
  belongs_to :repository

  enum :environment, { prod: 0, stage: 1, qa: 2 }

  validates :revision,    presence: true
  validates :date,        presence: true
  validates :user,        presence: true
  validates :revision, uniqueness: { scope: [ :repository_id, :environment ] }
end
