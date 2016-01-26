class AddPasswordToDropboxLinks < ActiveRecord::Migration
  def change
    add_column :dropbox_links, :password, :string
  end
end
