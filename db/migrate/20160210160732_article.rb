class Article < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.time :time
      t.integer :category_id
      t.integer :user_id
    end
  end
end
