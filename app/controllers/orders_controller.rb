class OrdersController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    def update
        order_items = params["order_items"]
        
        order_items.each do |order_item|
          @order_item = OrderItem.find_by(id: order_item["id"])
          @order_item.product_name = order_item["product_name"]
          @order_item.sorting = order_item["sorting"]
          @order_item.itemUUID = order_item["itemUUID"]
          @order_item.weight_per_product = order_item["weight_per_product"]
          @order_item.color = order_item["color"]
          @order_item.quantity_per_unit = order_item["quantity_per_unit"]
          @order_item.item_price = order_item["item_price"]
          @order_item.unit = order_item["unit"]
          @order_item.volume_per_unit = order_item["volume_per_unit"]
          @order_item.item_total_weight = order_item["item_total_weight"]
          @order_item.weight_per_unit = order_item["weight_per_unit"]
          @order_item.item_total_price = order_item["item_total_price"]
          @order_item.item_total_volume = order_item["item_total_volume"]
          @order_item.remarks = order_item["remarks"]
          @order_item.save
        end
        render :text => "success"
    end
    def edit
      @order = Order.find_by(id: params["id"])
      @orderitems = OrderItem.where(order_id: params["id"])
    end
    def create
      @order = Order.new order_params
      @order.save
      render :action => :edit
    end
    def index
      @orders = Order.all 
    end
    def order_params
      params.require(:order).permit(:customer_name, :supplier_name)
    end
    def upload_pic
      respond_to do |format|
        @orderitem = OrderItem.find_by(id: params["order_item_id"])
        @orderitem.image = params[:order][:picture]
        @orderitem.save
        @order = Order.find_by(id: @orderitem.order_id)
        format.js
        format.html { redirect_to "/orders/#{@orderitem.order_id}/edit" }
      end
    end
end
