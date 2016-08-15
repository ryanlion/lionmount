require 'spreadsheet'
require 'axlsx'
class ShipmentsController < ApplicationController
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    before_filter :admin_only, :except => [:index, :packing_list]
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
        redirect_to shipments_path, :flash => { :success => "Shipment Saved!" }
      else
        redirect_to shipments_path, :flash => { :error => "Shipment not Saved!" }
      end
    end
    def edit
      @shipment = Shipment.find_by(id: params[:id])
    end
    def index
        @shipments = Shipment.all
    end
    def check_style(styles,style_h) 
      
    end
    def packing_list
        @shipment = Shipment.find_by(id: params[:id])
        template = RubyXL::Parser.parse("public/system/spreadsheet/template/packing_template.xlsx")
        template_book = Spreadsheet.open 'public/system/spreadsheet/template/packing_template.xls'
        template_sheet = template_book.worksheet 0
        p = Axlsx::Package.new
        packing_list_book = p.workbook
        shipment = JSON.parse(@shipment.to_json)
        sheet = packing_list_book.add_worksheet(:name => "Packing List test")
        styles = []
        template.first.each {|row|
          row.cells.each{ |cell|
            style_h = {
              :fg_color => cell.font_color,
              :sz => cell.font_size.round,
              :font_name => cell.font_name,
              :border => { :color => 'FF000000', :style => :thin },
              :alignment => { :horizontal => cell.horizontal_alignment.to_sym, :vertical => cell.vertical_alignment.to_sym },
              :b => cell.is_bolded.nil? ? false : cell.is_bolded
            }
            styles << packing_list_book.styles.add_style (style_h)
require "bybug"; byebug
          }
        }
        

        header_rows = 0
        template_sheet.rows.each{ |row|
            values = JSON.parse(row.to_json)
            styles = []
            values.each_with_index{ |v,i|
              format = row.formats[i]
              horizontal = :center
              if format.horizontal_align == :default
                horizontal = :left
              else
              end
              unless v.nil? || v == ""
                style_hash = {
                  :bg_color => Color::CSS[format.pattern_fg_color.to_s].html.swapcase.gsub(/\#/,"FF"),
                  :fg_color=> Color::CSS[format.font.color .to_s].html.swapcase.gsub(/\#/,"FF"),
                  :sz=>format.font.size, 
                  :font_name => format.font.name, 
                  :border=> {:style => format.top, :color => "FF000000"},
                  :alignment => { :horizontal=> horizontal, :vertical => format.vertical_align }
                }
                n_style = packing_list_book.styles.add_style (style_hash)
                styles << n_style
              else
                styles << nil
              end
            }
            sheet.add_row values, :style => styles, :types => [:string]
          }
        packing_list_book.styles do |s|
          
          horizontal_center_cell =  s.add_style  :alignment => { :horizontal=> :center }, :border => Axlsx::STYLE_THIN_BORDER
          horizontal_center_cell_noborder =  s.add_style  :alignment => { :horizontal=> :center }
          #packing_list sheet
          packing_list_book.add_worksheet(:name => "Packing List") do |sheet|          
            
            sheet.column_widths 8,8,8,6,10,nil,20,nil,nil,nil,7,8,8,8

            sheet.add_row ["IN NO.","MARKS","CTN NO","DESCRIPTION","","ITEM CODE","SPECIFICATION","QTY/CTN","CTN","CBM","G.W","PRICE","AMOUNT","U.W","U.CBM","REMARKS"], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("D6:E6")

            @shipment.orders.each do |order|
              orderitems = OrderItem.where(order_id: order.id).order(:sorting)
              orderitems.each_with_index do |order_item, index|
                sheet.add_row [order.id, shipment["marks"],"","    ",
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
            
            sheet.add_row ["TO:",shipment["customer_name"],"","","","","",""]
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
            
            sheet.add_row ["TO:",shipment["customer_name"],"","","","","","",""]
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
  def admin_only
    unless current_user.admin?
      redirect_to :back, :alert => "Access denied."
    end
  end
end
