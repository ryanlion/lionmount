class Order < ActiveRecord::Base
    has_many :order_items
    has_many :shipment_order_relations
    has_many :shipments, through: :shipment_order_relations
end
