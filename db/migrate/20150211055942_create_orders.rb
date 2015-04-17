class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :customer_name
      t.string :supplier_name
      t.string :total_weight
      t.string :total_volume
      t.string :total_price
      t.string :supplier_english_name
      t.string :supplier_address
      t.string :supplier_contact_person
      t.string :supplier_contact_no
      t.string :supplier_email
      t.string :deposit
      t.string :marks

      t.timestamps
    end
  end
end
