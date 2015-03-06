class ShipmentsController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    def create
        debugger
        orders = params["selected"]
        uuid = params["ship-uuid"]
        orders.each do |order|
          @shipment = Shipment.new
          @shipment.order_id = order.order_id

          order
        end
        render :text => "success"
    end
end
