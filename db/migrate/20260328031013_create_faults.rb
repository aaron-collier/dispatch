class CreateFaults < ActiveRecord::Migration[8.1]
  def change
    create_table :faults do |t|
      t.references :repository,  null: false, foreign_key: true
      t.integer :environment,    null: false
      t.string  :revision,       null: false
      t.datetime :date,          null: false
      t.string  :title,          null: false
      t.string  :honeybadger_id, null: false

      t.timestamps
    end

    add_index :faults, :honeybadger_id, unique: true
  end
end
