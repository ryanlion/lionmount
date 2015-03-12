class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.string :shipment_uuid
      t.string :description
      t.string :status
      t.string :customer_name
      t.string :marks
      t.string :port_dispatch
      t.string :port_distination
      t.string :doc_date
      t.string :loading_date
      
      t.timestamps
    end
  end
end
