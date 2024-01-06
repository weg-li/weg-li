class RemoveProjectData < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        remove_column :users, :project_user_id
        remove_column :users, :project_access_token
      end
    end
  end
end
