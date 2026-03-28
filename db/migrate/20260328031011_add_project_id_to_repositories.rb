class AddProjectIdToRepositories < ActiveRecord::Migration[8.1]
  def change
    add_column :repositories, :project_id, :string
  end
end
