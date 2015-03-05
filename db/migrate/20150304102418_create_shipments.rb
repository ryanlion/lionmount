class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :order_id
      t.string :shipment_uuid
      
      t.timestamps
    end
  end
end
