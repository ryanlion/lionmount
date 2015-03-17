class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.belongs_to :ordr, index:true
      t.string :itemUUID
      t.string :order_id
      t.string :product_name
      t.string :packing
      t.string :image_uid
      t.string :title
      t.string :weight_per_product
      t.string :color
      t.string :quantiry_per_unit
      t.string :unit
      t.string :no_of_unit
      t.string :volume_per_unit
      t.string :item_total_weight
      t.string :weight_per_unit
      t.string :item_total_price
      t.string :item_total_volume
      t.string :remarks

      t.timestamps
    end
  end
end
