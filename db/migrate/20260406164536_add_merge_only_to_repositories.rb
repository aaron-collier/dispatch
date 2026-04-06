class AddMergeOnlyToRepositories < ActiveRecord::Migration[8.1]
  def change
    add_column :repositories, :merge_only, :boolean, default: false, null: false
  end
end
