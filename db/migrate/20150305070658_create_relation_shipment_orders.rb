class CreateRelationShipmentOrders < ActiveRecord::Migration
  def change
    create_table :relation_shipment_orders do |t|

      t.timestamps
    end
  end
end
