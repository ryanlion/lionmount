require 'spreadsheet'
class ShipmentsController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    def create
        orders = params["selected"]
        uuid = params["ship-uuid"]
        @shipment = Shipment.new
        @shipment.shipment_uuid = uuid
        @shipment.save
        orders.each do |order|
            @relation = ShipmentOrderRelation.new
            @relation.order_id = order["order_id"]
            @relation.shipment_id = @shipment.id
            @relation.save
        end
        render :index
    end
    def index
        byebug
        @shipments = Shipment.all
    end
    def packing_list
        @shipment = Shipment.find_by(id: params[:id])
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet::Workbook.new
        sheet_packing_list = book.create_worksheet
        sheet_packing_list.name = "Packing List"
        
        @shipment.orders do |order|
            order.order_items do |order_item|
                row = [order_item.product_name,order_item.packing]
                order_item
            end
        end
        render :text => "sucess"
    end
end
