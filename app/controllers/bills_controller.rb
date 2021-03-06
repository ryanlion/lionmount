class BillsController < ApplicationController
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
            byebug
            @orderitem.image = params[:picture]
            @orderitem.save
            format.html { redirect_to edit_order_order_item_path }
            format.js
        end
    end
    
    def photo_params
        params.require(:photo).permit(:image, :title)
    end
end
