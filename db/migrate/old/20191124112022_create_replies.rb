class CreateReplies < ActiveRecord::Migration[6.0]
  def change
    create_table :replies do |t|
      t.references :notice
      t.string :sender
      t.string :subject
      t.text :content

      t.timestamps
    end
  end
end
