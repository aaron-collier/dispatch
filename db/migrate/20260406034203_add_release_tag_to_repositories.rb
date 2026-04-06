class AddReleaseTagToRepositories < ActiveRecord::Migration[8.1]
  def change
    add_column :repositories, :release_tag, :string
  end
end
