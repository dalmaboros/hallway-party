class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.string :website, null: false
      t.string :location, null: false
      t.string :time_zone, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end

    add_check_constraint :events,
      "ends_at > starts_at",
      name: "events_ends_after_starts"

    add_index :events, :starts_at
  end
end
