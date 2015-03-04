class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :order_id

      t.timestamps
    end
  end
end
