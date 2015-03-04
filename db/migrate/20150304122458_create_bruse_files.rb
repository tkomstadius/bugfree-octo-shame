class CreateBruseFiles < ActiveRecord::Migration
  def change
    create_table :bruse_files do |t|
      t.string :name
      t.integer :identity_id
      t.string :foreign_ref
      t.string :type

      t.timestamps null: false
    end
  end
end
