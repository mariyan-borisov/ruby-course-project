class Comment < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :content
      t.datetime :time
      t.integer :article_id
      t.integer :user_id
    end
  end
end
