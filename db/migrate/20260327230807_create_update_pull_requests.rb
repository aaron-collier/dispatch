class CreateUpdatePullRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :update_pull_requests do |t|
      t.references :repository, null: false, foreign_key: true
      t.integer :pull_request,  null: false
      t.integer :status,        null: false, default: 0
      t.integer :build,         null: false, default: 0

      t.timestamps
    end

    add_index :update_pull_requests, :pull_request, unique: true
  end
end
