class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.string :itemUUID
      t.string :order_id
      t.string :product_name
      t.string :packing
      t.string :image_uid
      t.string :title

      t.timestamps
    end
  end
end
