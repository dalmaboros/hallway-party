class CreateUserHobbies < ActiveRecord::Migration[8.1]
  def change
    create_table :user_hobbies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :hobby, null: false, foreign_key: true

      t.timestamps

      t.index [:hobby_id, :user_id], unique: true
    end
  end
end
