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
    def create
      @order = Order.new order_params
      @order.save
      render :action => :edit
    end
    def index
      
    end
    def order_params
      params.require(:order).permit(:customer_name, :supplier_name)
   end
end
