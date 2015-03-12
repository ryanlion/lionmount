require 'spreadsheet'
require 'axlsx'
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
        redirect_to shipments_path
    end
    def update
      @shipment = Shipment.find_by(id: params[:id])
      if @shipment.update(shipment_params)
        flash[:success] = "Shipment Saved!"
        render 'edit'
      else
        flash[:error] = "Shipment not Saved!"
        render 'edit'
      end
    end
    def edit
      @shipment = Shipment.find_by(id: params[:id])
    end
    def index
        @shipments = Shipment.all
    end
    def packing_list
        @shipment = Shipment.find_by(id: params[:id])
        #template_book = Spreadsheet.open 'public/system/spreadsheet/template/real_packing_amount_template.xls'

        #template_sheet = template_book.worksheet 0

        p = Axlsx::Package.new
        packing_list_book = p.workbook

        packing_list_book.styles do |s|
          horizontal_center_cell =  s.add_style  :alignment => { :horizontal=> :center }
          packing_list_book.add_worksheet(:name => "Packing List") do |sheet|
            
            sheet.add_row ["LION INTERNATIONAL TRADING  CO.,LTD"], :style => [horizontal_center_cell ]
            sheet.merge_cells("A1:S1")
            
            sheet.add_row ["PACKING LIST"], :style => [horizontal_center_cell ]
            sheet.merge_cells("A2:S2")
            
            sheet.add_row ["CLIENT","",@shipment.customer_name,"","PORT OF DISPATCH","","",@shipment.port_dispatch,"","","DATE","","",@shipment.doc_date]

            sheet.add_row ["MARKS","",@shipment.marks,"","PORT OF DESTINATION","","",@shipment.port_distination,"","","LOADING DATE","","",@shipment.loading_date]

            sheet.add_row ["IN NO.","MARKS","DESCRIPTION","ITEM NO.","SPECIFICATION","QTY/CTN","CTN","CBM","G.W","PRICE","AMOUNT","U.W","U.CBM"], :style => Axlsx::STYLE_THIN_BORDER

            @shipment.orders.each do |order|
              order.order_items.each_with_index do |order_item, index|
                sheet.add_row [order_item.product_name, order_item.packing,'ssss']
              end
            end
          end
        end
        p.serialize("public/system/spreadsheet/spreadsheet.xlsx")
        send_file 'public/system/spreadsheet/spreadsheet.xlsx'
    end

    def generate_packing_list_head

    end
    def packing_list_1
        @shipment = Shipment.find_by(id: params[:id])
        template_book = Spreadsheet.open 'public/system/spreadsheet/template/real_packing_amount_template.xls'

        template_sheet = template_book.worksheet 0

        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet::Workbook.new
        packing_list_sheet= book.create_worksheet
        packing_list_sheet.name = "Packing List"

        template_sheet.each do |row|
          packing_list_sheet.row(packing_list_sheet.last_row_index+1).replace  row
        end
        packing_list_sheet.delete_row(0)
        @shipment.orders.each do |order|
            order.order_items.each_with_index do |order_item, index|
                packing_list_sheet.row(packing_list_sheet.last_row_index+1).replace [order_item.product_name, order_item.packing,'ssss']
            end
        end
        
        #book.write 'public/system/spreadsheet/spreadsheet.xls'
        file_contents = StringIO.new
        book.write file_contents
        send_data file_contents.string.force_encoding('binary'), filename: "spreadsheet.xls"
    end
private
  def shipment_params
    params.require(:shipment).permit(:shipment_uuid,:description,:status,:customer_name,:marks,:port_dispatch,:port_distination,:doc_date,:loading_date)
  end
end
