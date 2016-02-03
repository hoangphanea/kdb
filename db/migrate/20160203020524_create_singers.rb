class CreateSingers < ActiveRecord::Migration
  def change
    create_table :singers do |t|
      t.string :name
      t.string :link

      t.timestamps null: false
    end

    add_index :singers, :name
  end
end
