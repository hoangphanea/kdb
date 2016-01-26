class AddStypeToDropboxLinks < ActiveRecord::Migration
  def change
    add_column :dropbox_links, :stype, :string
  end
end
