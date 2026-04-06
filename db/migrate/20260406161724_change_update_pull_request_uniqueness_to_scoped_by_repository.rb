class ChangeUpdatePullRequestUniquenessToScopedByRepository < ActiveRecord::Migration[8.1]
  def change
    remove_index :update_pull_requests, :pull_request
    add_index :update_pull_requests, [ :repository_id, :pull_request ], unique: true
  end
end
