class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :shipment_uuid
      t.string :description
      t.string :status
      t.string :customer_name
      
      t.timestamps
    end
  end
end
