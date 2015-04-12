require "uuidtools"
require 'json'
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
      respond_to do |format|
        @orderitem = OrderItem.new 
        @orderitem.itemUUID = UUIDTools::UUID.timestamp_create.to_s
        @orderitem.order_id = params["order_id"]
        unless params[:rowno].nil?
          @rowno = OrderItem.find(params[:rowno]).sorting.to_i
        end
        @orderitem.save
        
        format.js
        format.html { redirect_to "/orders/#{@orderitem.order_id}/edit" }
      end
    end
    def destroy
      respond_to do |format|
        @orderitem = OrderItem.find(params[:id])
        @orderitem.destroy
     
        format.js
        format.html { redirect_to "/orders/#{@orderitem.order_id}/edit" }
      end
    end
    def delete_order_items      
      items = JSON.parse(params["item_ids"])
      items["idarr"].each do |id|
        @orderitem = OrderItem.find(id)
        @orderitem.destroy
      end
      render :text => "success"
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
