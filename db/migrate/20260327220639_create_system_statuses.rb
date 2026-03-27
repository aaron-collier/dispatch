class CreateSystemStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :system_statuses do |t|
      t.string :name, null: false
      t.boolean :connected, null: false, default: false

      t.timestamps
    end

    add_index :system_statuses, :name, unique: true
  end
end
