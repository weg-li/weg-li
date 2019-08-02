class AddFieldsToArticles < ActiveRecord::Migration[4.2]
  def change
    add_column :articles, :title, :string
    add_column :articles, :body, :text
    add_column :articles, :user_id, :integer
    add_column :articles, :published_at, :timestamp
    add_column :articles, :tags, :string, default: [], array: true
  end
end
