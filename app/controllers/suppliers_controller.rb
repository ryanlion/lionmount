class SuppliersController < ApplicationController
  def find_suppliers
    respond_to do |format|
      if $redis.get('suppliers').nil? 
        $redis.set('suppliers',Supplier.all.to_json)
      end
      @suppliers = JSON.parse($redis.get('suppliers'))
      @suppliers = @suppliers.select{|s| s["supplier_name"].include? params["supplier_code"] }
      format.js
      format.html { redirect_to "/orders/new" }
    end
  end
  def show
  end
  def create
    @supplier = Supplier.new params["supplier"].symbolize_keys
    @supplier.save
    $redis.set('suppliers',Supplier.all.to_json)
    render 'new'
  end
end
