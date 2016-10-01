class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :title
      t.string :quest
      t.string :answer

      t.timestamps null: false
    end
  end
end
