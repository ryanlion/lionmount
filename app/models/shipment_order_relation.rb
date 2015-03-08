class ShipmentOrderRelation < ActiveRecord::Base
    belongs_to :order
    belongs_to :shipment
end
