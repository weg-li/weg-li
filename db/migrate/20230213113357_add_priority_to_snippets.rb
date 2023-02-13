class AddPriorityToSnippets < ActiveRecord::Migration[7.0]
  def change
    add_column :snippets, :priority, :integer, default: 0
  end
end
