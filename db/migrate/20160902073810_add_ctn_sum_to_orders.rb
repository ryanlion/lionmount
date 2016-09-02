class AddCtnSumToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :total_ctns, :string
  end
end
