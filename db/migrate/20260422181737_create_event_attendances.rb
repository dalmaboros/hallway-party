class CreateEventAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :event_attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps

      t.index [:user_id, :event_id], unique: true
    end
  end
end
