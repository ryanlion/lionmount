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
          horizontal_center_cell =  s.add_style  :alignment => { :horizontal=> :center }, :border => Axlsx::STYLE_THIN_BORDER
          horizontal_center_cell_noborder =  s.add_style  :alignment => { :horizontal=> :center }
          #packing_list sheet
          packing_list_book.add_worksheet(:name => "Packing List") do |sheet|          
            sheet.add_row ["LION INTERNATIONAL TRADING  CO.,LTD","","","","","","","","","","","","","","",""], :style => horizontal_center_cell, :types => [:string]
            sheet.merge_cells("A1:P1")
            
            sheet.add_row ["PACKING LIST","","","","","","","","","","","","","","",""], :style => horizontal_center_cell_noborder, :types => [:string]
            sheet.merge_cells("A2:P2")
            
            sheet.add_row ["CLIENT",@shipment.customer_name,"","","PORT OF DISPATCH","",@shipment.port_dispatch,"","","","DATE",@shipment.doc_date,"",""], :style => horizontal_center_cell_noborder
            sheet.merge_cells("B3:D3")
            sheet.merge_cells("E3:F3")
            sheet.merge_cells("G3:J3")
            sheet.merge_cells("K3:L3")
            sheet.merge_cells("M3:P3")

            sheet.add_row ["MARKS",@shipment.marks,"","","PORT OF DESTINATION","",@shipment.port_distination,"","","","LOADING DATE",@shipment.loading_date,"",""], :style => horizontal_center_cell_noborder
            sheet.merge_cells("B4:D4")
            sheet.merge_cells("E4:F4")
            sheet.merge_cells("G4:J4")
            sheet.merge_cells("K4:L4")
            sheet.merge_cells("M4:P4")
            
            sheet.add_row ["C. No",@shipment.marks,"","","SEAL NO.","",@shipment.port_distination,"","","","BL NO","",""], :style => horizontal_center_cell_noborder
            sheet.merge_cells("B5:D5")
            sheet.merge_cells("E5:F5")
            sheet.merge_cells("G5:J5")
            sheet.merge_cells("K5:L5")
            sheet.merge_cells("M5:P5")
            
             
            sheet.column_widths 8,8,8,6,10,nil,20,nil,nil,nil,7,8,8,8

            sheet.add_row ["IN NO.","MARKS","CTN NO","DESCRIPTION","","ITEM CODE","SPECIFICATION","QTY/CTN","CTN","CBM","G.W","PRICE","AMOUNT","U.W","U.CBM","REMARKS"], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("D6:E6")

            @shipment.orders.each do |order|
              orderitems = OrderItem.where(order_id: order.id).order(:sorting)
              orderitems.each_with_index do |order_item, index|
                sheet.add_row [order.id, @shipment.marks,"","    ",
                  order_item.product_name,order_item.product_code,
                  order_item.spec,order_item.quantity_per_unit,
                  order_item.no_of_unit,order_item.item_total_volume,
                  order_item.item_total_weight,
                  order_item.discount == "0" ? order_item.item_price : order_item.item_price.to_f - order_item.discount.to_f,
                  order_item.item_total_price,order_item.weight_per_unit,
                  order_item.item_total_weight,order_item.remarks], 
                  :style => horizontal_center_cell,:height => 55
                  
                  row_no = sheet.rows.length
                  
                  unless order_item.image_uid.nil? then
                    img = File.expand_path("#{Rails.root}/public#{order_item.image.remote_url}", __FILE__)
                    sheet.add_image(:image_src => img, :noSelect => false, :noMove => false) do |image|

                      image.width=100
                      image.height=66
                      image.start_at 3, row_no-1
                    end
                  else
                    sheet.merge_cells("D#{row_no}:D#{row_no-1}")
                  end

              end
            end
             sheet.add_row ["TOTAL","","","","","","","","=SUM(I6:I#{sheet.rows.length})","=SUM(J6:J#{sheet.rows.length})","=SUM(K6:K#{sheet.rows.length})",
                "","=SUM(M5:M#{sheet.rows.length})","","",""], :style => horizontal_center_cell
          end
          #customs clearance invoice
          packing_list_book.add_worksheet(:name => "Invoice") do |sheet|          
            sheet.add_row ["","","","","","","","",""], :types => [:string], :style => horizontal_center_cell_noborder
            sheet.merge_cells("A1:H1")
            
            sheet.add_row ["INVOICE","","","","","","",""], :types => [:string], :style => horizontal_center_cell_noborder
            sheet.merge_cells("A2:H2")
            
            sheet.add_row ["TO:",@shipment.customer_name,"","","","","",""]
            sheet.merge_cells("B3:D3")
            sheet.merge_cells("F3:J3")

            sheet.add_row ["TEL:","","","","","INVOICE NO.:","",""]
            sheet.merge_cells("B4:C4")
            sheet.merge_cells("F4:G4")
             
            sheet.add_row ["FAX:","","","","","DATE:","",""]
            sheet.merge_cells("B5:C5")
            sheet.merge_cells("F5:G5")

            sheet.add_row ["C. NO.:","","","","","SEAL NO.:","",""]
            sheet.merge_cells("B6:C6")
            sheet.merge_cells("F6:G6")

            sheet.add_row ["FROM:","","","TO:","","","BY:","SEA"]
            sheet.merge_cells("B7:C7")
            sheet.merge_cells("E7:F7")

            sheet.column_widths nil,nil,nil,nil,nil,nil,nil,8

            sheet.add_row ["MARKS","ITEM CODE","DESCRIPTION","QTY/CTN","","CTNS","U.PRICE","AMOUNT",], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("D8:E8")

            @shipment.orders.each do |order|
              orderitems = OrderItem.where(order_id: order.id).order(:sorting)
              orderitems.each_with_index do |order_item, index|
                sheet.add_row [
                  order.marks, order_item.product_code,
                  order_item.product_name,
                  order_item.quantity_per_unit,order_item.single_unit,
                  order_item.no_of_unit,order_item.item_price,
                  order_item.item_total_price], 
                  :style => horizontal_center_cell,:height => 55
                  
              end
            end
             sheet.add_row ["TOTAL","","","","","=SUM(F9:F#{sheet.rows.length})","","=SUM(H9:H#{sheet.rows.length})"], :style => horizontal_center_cell
          end
          
          #customs packing list
          packing_list_book.add_worksheet(:name => "BL-PACKING LIST") do |sheet|          
            sheet.add_row ["","","","","","","","","",""], :style => horizontal_center_cell, :types => [:string]
            sheet.merge_cells("A1:N1")
            
            sheet.add_row ["INVOICE","","","","","","","",""], :style => horizontal_center_cell, :types => [:string]
            sheet.merge_cells("A2:N2")
            
            sheet.add_row ["TO:",@shipment.customer_name,"","","","","","",""]
            sheet.merge_cells("B3:D3")
            sheet.merge_cells("F3:J3")

            sheet.add_row ["TEL:","","","","","","INVOICE NO.:","",""]
            sheet.merge_cells("B4:E4")
            sheet.merge_cells("H4:I4")
             
            sheet.add_row ["FAX:","","","","","","DATE:","",""]
            sheet.merge_cells("B5:C5")
            sheet.merge_cells("H5:I5")

            sheet.add_row ["C. NO.:","","","","","","SEAL NO.:","",""]
            sheet.merge_cells("B6:C6")
            sheet.merge_cells("F6:G6")

            sheet.add_row ["FROM:","","","TO:","","","","BY:","SEA"]
            sheet.merge_cells("B7:C7")
            sheet.merge_cells("E7:G7")

            sheet.column_widths nil,nil,nil,nil,nil,nil,nil,8

            sheet.add_row ["MARKS","ITEM CODE","DESCRIPTION","QTY/CTN","","CTNS","CBM","G.W","N.W"], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("D8:E8")

            @shipment.orders.each do |order|
              orderitems = OrderItem.where(order_id: order.id).order(:sorting)
              orderitems.each_with_index do |order_item, index|
                sheet.add_row [
                  order.marks, order_item.product_code,
                  order_item.product_name,
                  order_item.quantity_per_unit,order_item.single_unit,
                  order_item.no_of_unit,order_item.item_price,
                  order_item.item_total_price], 
                  :style => horizontal_center_cell,:height => 55

              end
            end
             sheet.add_row ["TOTAL","","","","","=SUM(F9:F#{sheet.rows.length})","","=SUM(H9:H#{sheet.rows.length})"], :style => horizontal_center_cell
          end
        end
        p.serialize("public/system/spreadsheet/spreadsheet.xlsx")
        send_file 'public/system/spreadsheet/spreadsheet.xlsx'
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
