class OrdersController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    def update
        order_items = params["order_items"]
        
        order_items.each do |order_item|
          @order_item = OrderItem.find_by(id: order_item["id"])
          @order_item.product_name = order_item["product_name"]
          @order_item.sorting = order_item["sorting"]
          @order_item.itemUUID = order_item["itemUUID"]
          @order_item.weight_per_product = order_item["weight_per_product"]
          @order_item.color = order_item["color"]
          @order_item.quantity_per_unit = order_item["quantity_per_unit"]
          @order_item.item_price = order_item["item_price"]
          @order_item.unit = order_item["unit"]
          @order_item.no_of_unit = order_item["no_of_unit"]
          @order_item.volume_per_unit = order_item["volume_per_unit"]
          @order_item.item_total_weight = order_item["item_total_weight"]
          @order_item.weight_per_unit = order_item["weight_per_unit"]
          @order_item.item_total_price = order_item["item_total_price"]
          @order_item.item_total_volume = order_item["item_total_volume"]
          @order_item.remarks = order_item["remarks"]
          @order_item.save
        end
        @order = Order.find_by(id: params["id"])
        @order.total_price = params["order_total_price"]
        @order.total_weight = params["order_total_weight"]
        @order.total_volume = params["order_total_volume"]
        @order.save

        render :text => "success"
    end
    def edit
      @order = Order.find_by(id: params["id"])
      @orderitems = OrderItem.where(order_id: params["id"]).order(:sorting)
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
      params.require(:order).permit(:customer_name, :supplier_name,:supplier_english_name,
        :supplier_address, :supplier_contact_person, :supplier_contact_no,:supplier_email)
    end
    def order_xlsx
      @order = Order.find_by(id: params[:id])
        #template_book = Spreadsheet.open 'public/system/spreadsheet/template/real_packing_amount_template.xls'

        #template_sheet = template_book.worksheet 0

        p = Axlsx::Package.new
        packing_list_book = p.workbook

        packing_list_book.styles do |s|
          horizontal_center_cell =  s.add_style  :alignment => { :horizontal=> :center }, :border => Axlsx::STYLE_THIN_BORDER
          packing_list_book.add_worksheet(:name => "Purchase Contract") do |sheet|          
            sheet.add_row ["Purchase Contract"], :style => horizontal_center_cell, :types => [:string]
            sheet.merge_cells("A1:L1")
            
            
            sheet.add_row ["Buyer:","", "LION INTERNATIONAL TRADING  CO.,LTD","","Supplier:","","","","",@order.supplier_name,"",""], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("A2:B2")
            sheet.merge_cells("C2:D2")
            sheet.merge_cells("E2:F2")
            sheet.merge_cells("G2:L2")

            sheet.add_row ["Address:","", "","","Supplier Address:","","","","",@order.supplier_address,"",""], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("A3:B3")
            sheet.merge_cells("C3:D3")
            sheet.merge_cells("E3:F3")
            sheet.merge_cells("G3:L3")

            sheet.add_row ["Buyer Contact","","","","Supplier Contact","","","","",@order.supplier_contact_person,"",""], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("A4:B4")
            sheet.merge_cells("C4:D4")
            sheet.merge_cells("E4:F4")
            sheet.merge_cells("G4:L4")

            sheet.add_row ["Buyer Contact No","","","","Supplier Contact No","","","","",@order.supplier_contact_no,"",""], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("A5:B5")
            sheet.merge_cells("C5:D5")
            sheet.merge_cells("E5:F5")
            sheet.merge_cells("G5:L5")

            sheet.add_row ["Buyer Contact Email:","","","","Supplier Contact Email:","","","","",@order.supplier_email,"",""], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("A6:B6")
            sheet.merge_cells("C6:D6")
            sheet.merge_cells("E6:F6")
            sheet.merge_cells("G6:L6")

            sheet.add_row ["PICTURE","PRODUCT NAME","SPECIFICATION","WEIGHT","QTY PER UNIT","UNIT","UNIT QTY","ITEM PRICE","PRICE SUB TOTAL","WEIGHT SUB TOTAL","CBM SUB TOTAL","REMARKS"], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("C7:D7")
            @orderitems = OrderItem.where(order_id: params["id"]).order(:sorting)
            @orderitems.each_with_index do |order_item, index|
              sheet.add_row ["", order_item.product_name,order_item.color,
                              order_item.weight_per_unit,order_item.quantity_per_unit, 
                             order_item.unit,order_item.no_of_unit,
                             order_item.item_price,order_item.item_total_price,
                             order_item.item_total_weight,order_item.item_total_weight,
                             order_item.remarks],
                             :style => horizontal_center_cell,:height => 55

              row_no = sheet.rows.length

              unless order_item.image_uid.nil? then
                img = File.expand_path("#{Rails.root}/public#{order_item.image.remote_url}", __FILE__)
                sheet.add_image(:image_src => img, :noSelect => false, :noMove => false) do |image|

                  image.width=100
                  image.height=66
                  image.start_at 0, row_no-1
                end
              else
                sheet.merge_cells("A#{row_no}:A#{row_no-1}")
              end

            end
         end
        end
        p.serialize("public/system/spreadsheet/spreadsheet.xlsx")
        send_file 'public/system/spreadsheet/spreadsheet.xlsx'
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
