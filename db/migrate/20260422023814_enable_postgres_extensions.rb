class EnablePostgresExtensions < ActiveRecord::Migration[8.1]
  def change
    enable_extension "vector"
    enable_extension "citext"
  end
end
