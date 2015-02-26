class OrderItemsController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    def update
        orders = JSON.parse(request.raw_post)
        orders["order_items"].each do |order|
          @order_item = OrderItem.new(order)
          @order_item.save
        end
        render :text => "success"
    end
    def create
      @orderitem = OrderItem.new 
      @orderitem.itemUUID = params["uuid"]
      @orderitem.order_id = params["order_id"]
      @orderitem.save
      render :text => @orderitem.id
    end
    def upload_pic
      debugger
      render :text => "success"
    end
end
