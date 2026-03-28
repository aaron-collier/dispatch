class IntegrationTest < ApplicationRecord
  has_many :test_runs, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
