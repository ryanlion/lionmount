class AddImageUidToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :site_logo_uid, :string
  end
end
