class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :image_uid
      t.string :site_name
      t.timestamps
    end
  end
end
