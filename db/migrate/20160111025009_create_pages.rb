class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.integer :page_num

      t.timestamps null: false
    end

    add_index :pages, :page_num
  end
end
