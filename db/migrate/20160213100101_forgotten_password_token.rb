class ForgottenPasswordToken < ActiveRecord::Migration
  def change
    create_table :forgotten_password_tokens do |t|
      t.string :token
      t.integer :user_id
    end
  end
end
