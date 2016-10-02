class QuestionAddColumnCategory < ActiveRecord::Migration
  def change
    add_column :questions, :category, :string
  end
end
