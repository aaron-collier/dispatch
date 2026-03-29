class AddExpiresAtToSystemStatuses < ActiveRecord::Migration[8.1]
  def change
    add_column :system_statuses, :expires_at, :datetime
  end
end
