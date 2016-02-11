class User < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :user_name
      t.string :password_hash
      t.datetime :time
      t.boolean :is_admin, null: false, default: false
    end
  end
end
