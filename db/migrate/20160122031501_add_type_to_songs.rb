class AddTypeToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :stype, :string, default: ''
    add_index :songs, :stype
  end
end
