class AddCheckToSingers < ActiveRecord::Migration
  def change
    add_column :singers, :check, :boolean, default: false
    add_index :singers, :check
  end
end
