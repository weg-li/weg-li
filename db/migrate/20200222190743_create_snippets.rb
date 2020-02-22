class CreateSnippets < ActiveRecord::Migration[6.0]
  def change
    create_table :snippets do |t|
      t.references :user
      t.string :name
      t.text :content

      t.timestamps
    end
  end
end
