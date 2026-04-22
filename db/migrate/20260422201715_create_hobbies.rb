class CreateHobbies < ActiveRecord::Migration[8.1]
  def change
    create_table :hobbies do |t|
      t.citext :name, null: false
      t.timestamps

      t.index :name, unique: true
    end

    add_column :hobbies, :embedding, :vector, limit: 1536
    add_index :hobbies, :embedding,
      using: :hnsw,
      opclass: :vector_cosine_ops
  end
end
