class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :supplier
      t.belongs_to :user, index:true
      t.string :total_weight
      t.string :total_volume
      t.string :total_price
      t.string :deposit
      t.string :marks

      t.timestamps
    end
  end
end
