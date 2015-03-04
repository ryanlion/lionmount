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
      respond_to do |format|
          @orderitem = OrderItem.find_by(id: params["order_item_id"])
          @orderitem.image = params[:picture]
          @orderitem.save
          @order = Order.find_by(id: @orderitem.order_id)
          format.js
          format.html { redirect_to "/orders/#{@orderitem.order_id}/edit" }
      end
    end
    
    def photo_params
        params.require(:photo).permit(:image, :title)
    end
end
