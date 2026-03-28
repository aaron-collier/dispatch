class CreateDeployments < ActiveRecord::Migration[8.1]
  def change
    create_table :deployments do |t|
      t.references :repository, null: false, foreign_key: true
      t.integer :environment, null: false
      t.string  :revision,    null: false
      t.datetime :date,       null: false
      t.string :user,        null: false

      t.timestamps
    end

    add_index :deployments, [ :repository_id, :revision, :environment ], unique: true, name: "index_deployments_on_repo_revision_env"
  end
end
