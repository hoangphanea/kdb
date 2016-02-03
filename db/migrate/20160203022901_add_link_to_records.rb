class AddLinkToRecords < ActiveRecord::Migration
  def change
    add_column :records, :link, :string
  end
end
