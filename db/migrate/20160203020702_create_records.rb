class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.references :singer, index: true, foreign_key: { on_delete: :cascade }
      t.references :song, index: true, foreign_key: { on_delete: :cascade }
      t.integer :hit_count, default: 0

      t.timestamps null: false
    end

    add_index :records, :hit_count
  end
end
