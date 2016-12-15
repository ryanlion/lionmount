class ChangeShipmentsColumnType < ActiveRecord::Migration
  def up
    change_column :shipment_order_relations, :order_id, :integer
    change_column :shipment_order_relations, :shipment_id, :integer
  end

  def down
    change_column :shipment_order_relations, :order_id, :string
    change_column :shipment_order_relations, :shipment_id, :string
  end
end
