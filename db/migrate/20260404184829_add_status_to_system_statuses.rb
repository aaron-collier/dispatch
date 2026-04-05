class AddStatusToSystemStatuses < ActiveRecord::Migration[8.1]
  def change
    add_column :system_statuses, :status, :string
  end
end
