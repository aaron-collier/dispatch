class CreateTestRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :test_runs do |t|
      t.references :integration_test, null: false, foreign_key: true
      t.integer :duration
      t.string :status, null: false, default: "queuing"
      t.text :output
      t.string :druid
      t.string :collection_druid

      t.timestamps
    end
  end
end
