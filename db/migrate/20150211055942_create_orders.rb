class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.string :supplier_name
      t.string :total_weight
      t.string :total_volume
      t.string :total_price

      t.timestamps
    end
  end
end
