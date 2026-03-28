class CreateIntegrationTests < ActiveRecord::Migration[8.1]
  def change
    create_table :integration_tests do |t|
      t.string :name, null: false
      t.text   :description

      t.timestamps
    end

    add_index :integration_tests, :name, unique: true
  end
end
