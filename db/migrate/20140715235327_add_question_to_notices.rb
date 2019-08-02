class AddQuestionToNotices < ActiveRecord::Migration[4.2]
  def change
    add_column :notices, :question, :string
  end
end
