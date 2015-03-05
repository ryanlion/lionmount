class Shipment < ActiveRecord::Base
  has_many :order, though: :relation_shipment_order
  accepts_nested_attributes_for :order,
    :allow_destroy => true
  accepts_nested_attributes_for :ingredients,
    :allow_destroy => true

end
