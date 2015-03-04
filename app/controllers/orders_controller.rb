class OrdersController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    def update
        orders = JSON.parse(request.raw_post)
        orders["order_items"].each do |order|
          @order_item = OrderItem.new(order)
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
