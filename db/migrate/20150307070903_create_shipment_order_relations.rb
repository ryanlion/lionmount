class CreateShipmentOrderRelations < ActiveRecord::Migration
  def change
    create_table :shipment_order_relations do |t|
      t.belongs_to :order, index: true
      t.belongs_to :shipment, index: true
      t.integer :order_id
      t.integer :shipment_id
      
      t.timestamps
    end
  end
end
