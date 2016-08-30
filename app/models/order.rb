class Order < ActiveRecord::Base
    belongs_to :user
    belongs_to :supplier
    belongs_to :follower, :class_name => "User", :foreign_key => "follower_id"
    has_many :order_items
    has_many :shipment_order_relations
    has_many :shipments, through: :shipment_order_relations
end
