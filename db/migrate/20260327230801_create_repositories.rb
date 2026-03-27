class CreateRepositories < ActiveRecord::Migration[8.1]
  def change
    create_table :repositories do |t|
      t.string  :name,                 null: false
      t.date    :last_updated
      t.boolean :cocina_models_update, null: false, default: false
      t.text    :exclude_envs
      t.text    :non_standard_envs
      t.boolean :skip_audit,           null: false, default: false

      t.timestamps
    end

    add_index :repositories, :name, unique: true
  end
end
