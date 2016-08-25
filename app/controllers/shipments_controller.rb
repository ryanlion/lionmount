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
    def load_header_values(shipment,user)
      {
        "customer" => user.name,
        "shipment_port_of_dispatch" => shipment.port_dispatch,
        "shipment_order_date" => shipment.doc_date,
        "shipment_loading_date" => shipment.loading_date,
        "shipment_marks" => shipment.marks,
        "shipment_port_of_destination" => shipment.port_destination,
        "shipment_container_no" => shipment.container_no,
        "shipment_seal_no" => shipment.seal_no,
        "shipment_bl_no" => shipment.bl_no,
        "user_contact_no" => user.contact_no,
        "user_fax" => user.fax,
        "user_address" => user.address,
        "user_email" => user.email
      }
    end
    def to_alphabet(i)
      i.to_s(26).tr( "123456789abcdefghijklmnopqr", "abcdefghijklmnopqrstuvwxyz" ).upcase
    end
    def merge_cells(sheet,template)
      template.first.merged_cells.each{|cell_range|
        col_range = cell_range.ref.col_range.to_a
        row_range = cell_range.ref.row_range.to_a
        cell_start = "#{to_alphabet(col_range.first+1)}#{row_range.first+1}"
        cell_end = "#{to_alphabet(col_range.last+1)}#{row_range.last+1}"
        sheet.merge_cells("#{cell_start}:#{cell_end}")
      }
    end
    def set_column_width(sheet,template) 
      widths = []
      template.first.merge_cells.first.ref.col_range.each{|n|
        widths << template.first.get_column_width(n).to_i
      }
      sheet.column_widths(*widths)
    end
    def packing_list
        @shipment = Shipment.find_by(id: params[:id])
        template = RubyXL::Parser.parse("public/system/spreadsheet/template/packing_template.xlsx")
        p = Axlsx::Package.new
        packing_list_book = p.workbook
	horizontal_center_cell = packing_list_book.styles.add_style({ :alignment => { :horizontal=> :center }, :border => Axlsx::STYLE_THIN_BORDER })
        shipment = JSON.parse(@shipment.to_json)
        shipment_users = @shipment.orders.collect{ |o| o.user }.uniq
        sheets = {}
        styles = []
        field_order = []
        image_column = 0
        shipment_users.each{|user|
          header_value = load_header_values(@shipment,user)
          sheet = packing_list_book.add_worksheet(:name => "Packing List--#{user.name}")
          sheets[user.name] = sheet 
          section = "Header"
          template.first.each {|row|
            row_styles = []
            row_values = []
            row.cells.each{ |cell|
              h_alignment = cell.horizontal_alignment.to_sym rescue :center
              v_alignment = cell.vertical_alignment.to_sym rescue :center
              section = "Content" if cell.value == "#ContentBegin#"
              if section == "Header"
                style_h = {
                  :fg_color => cell.font_color,
                  :sz => cell.font_size.round,
                  :font_name => cell.font_name,
                  :border => { :color => 'FF000000', :style => :thin },
                  :alignment => { :horizontal => h_alignment, :vertical => v_alignment },
                  :b => cell.is_bolded.nil? ? false : cell.is_bolded
                }
                val = (cell.value.nil? ? nil : cell.value.tr('\"',""))
                row_values << (header_value[val].nil? ? cell.value : header_value[val])
                row_styles << packing_list_book.styles.add_style(style_h)
              elsif section == "Content"
                  image_column = cell.column if !cell.value.nil? && cell.value.include?("image")
                  field_order << cell.value
              end
            }
            sheets[user.name].add_row row_values, :style => row_styles, :types => [:string] unless row_values.compact.empty?
          }
        }
        
        @shipment.orders.each { |order|
          orderitems = OrderItem.where(order_id: order.id).order(:sorting)
          orderitems_formatted = orderitems.map {|item|
            {
              "order_id" => item.order_id,
              "supplier_name" => order.supplier.supplier_name,
              "supplier_contact_no" => order.supplier.supplier_contact_no,
              "image_space" => "",
              "product_code" => item.product_code,
              "prodect_name" => item.product_name,
              "spec" => item.spec,
              "quantity_per_unit" => item.quantity_per_unit,
              "no_of_unit" => item.no_of_unit,
              "item_total_volume" => item.item_total_volume,
              "item_total_weight" => item.item_total_weight,
              "item_price" => item.item_price,
              "item_total_price" => item.item_total_price,
              "volume_per_unit" => item.volume_per_unit,
              "weight_per_unit" => item.weight_per_unit,
              "image" => item.image.remote_url
            }
          }
          orderitems_formatted.each_with_index {|item, index|
            arr = item.values.first item.values.size-1
            sheets[order.user.name].add_row arr, :style => horizontal_center_cell,:height => 55
            row_no = sheets[order.user.name].rows.length
            
            unless item["image"].nil? || item["image"].blank? then
              img = File.expand_path("#{Rails.root}/public#{item["image"]}", __FILE__)
              sheets[order.user.name].add_image(:image_src => img, :noSelect => false, :noMove => false) do |image|
                image.width=100
                image.height=66
                image.start_at image_column, row_no-1
              end
            else
              sheets[order.user.name].merge_cells("D#{row_no}:D#{row_no-1}")
            end
          }
        }
        sheets.keys.each{|key|
          sheets[key].add_row ["TOTAL","","","","","","","","=SUM(I6:I#{sheets[key].rows.length})","=SUM(J6:J#{sheets[key].rows.length})","=SUM(K6:K#{sheets[key].rows.length})",
             "","=SUM(M5:M#{sheets[key].rows.length})","","",""], :style => horizontal_center_cell
          set_column_width(sheets[key],template)
          merge_cells(sheets[key],template)
        }
        packing_list_book.styles do |s|
          
          horizontal_center_cell =  s.add_style  :alignment => { :horizontal=> :center }, :border => Axlsx::STYLE_THIN_BORDER
          horizontal_center_cell_noborder =  s.add_style  :alignment => { :horizontal=> :center }
          #packing_list sheet
          packing_list_book.add_worksheet(:name => "Packing List") do |sheet|          
            
            sheet.column_widths 8,8,8,6,10,nil,20,nil,nil,nil,7,8,8,8

            sheet.add_row ["IN NO.","MARKS","CTN NO","DESCRIPTION","","ITEM CODE","SPECIFICATION","QTY/CTN","CTN","CBM","G.W","PRICE","AMOUNT","U.W","U.CBM","REMARKS"], :style => Axlsx::STYLE_THIN_BORDER
            sheet.merge_cells("D6:E6")

            
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
    params.require(:shipment).permit(:shipment_uuid,:description,:status,:customer_name,:marks,:port_dispatch,:port_destination,:doc_date,:loading_date,:bl_no,:seal_no,:container_no)
  end
  def admin_only
    unless current_user.admin?
      redirect_to :back, :alert => "Access denied."
    end
  end
end
