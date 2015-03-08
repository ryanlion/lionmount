class Shipment < ActiveRecord::Base
    has_many :shipment_order_relations
    has_many :orders, through: :shipment_order_relations
end