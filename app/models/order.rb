class Order < ActiveRecord::Base
    belongs_to :user
    belongs_to :supplier
    has_many :order_items
    has_many :shipment_order_relations
    has_many :shipments, through: :shipment_order_relations
end
