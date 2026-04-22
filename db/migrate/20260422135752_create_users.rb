class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      # OAuth identity
      t.string :provider, null: false
      t.string :uid, null: false

      # Display / identity
      t.string :username, null: false
      t.string :name, null: false
      t.string :pronouns

      # Contact
      t.string :email

      # Profile
      t.string :avatar_url
      t.text :bio
      t.string :location
      t.string :website
      t.string :linkedin_url
      t.string :mastodon_url
      t.string :bluesky_url
      t.string :twitter_url

      # Preferences
      t.boolean :email_notifications_enabled, null: false, default: true

      t.timestamps
    end

    add_index :users, [:provider, :uid], unique: true
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end
