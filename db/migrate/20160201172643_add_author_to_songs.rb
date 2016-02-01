class AddAuthorToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :author, :string
  end
end
