class UpdatePullRequest < ApplicationRecord
  belongs_to :repository

  enum :status, { open: 0, closed: 1, merged: 2 }, prefix: :status
  enum :build,  { passing: 0, failing: 1, building: 2 }, prefix: :build

  validates :pull_request, presence: true, uniqueness: { scope: :repository_id }
end
