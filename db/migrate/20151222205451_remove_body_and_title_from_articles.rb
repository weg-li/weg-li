class RemoveBodyAndTitleFromArticles < ActiveRecord::Migration[4.2]
  def change
    remove_column :articles, :title
    remove_column :articles, :body
  end
end
