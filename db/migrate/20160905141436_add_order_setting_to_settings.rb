class AddOrderSettingToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :order_logo_height, :integer
    add_column :settings, :order_logo_width, :integer
  end
end
