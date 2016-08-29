require_relative "../helps/doc_helper"
class OrdersController < ApplicationController
  include DocHelper
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    before_filter :admin_only, :except => [:index, :packing_list]
    def update
        order_items = params["order_items"]
        
        order_items.each do |order_item|
          @order_item = OrderItem.find_by(id: order_item["id"])
          @order_item.product_code = order_item["product_code"]
          @order_item.product_name = order_item["product_name"]
          @order_item.product_name_eng = order_item["product_name_eng"]
          @order_item.sorting = order_item["sorting"]
          @order_item.itemUUID = order_item["itemUUID"]
          @order_item.weight_per_product = order_item["weight_per_product"]
          @order_item.spec = order_item["spec"]
          @order_item.spec_eng = order_item["spec_eng"]
          @order_item.quantity_per_unit = order_item["quantity_per_unit"]
          @order_item.single_unit = order_item["single_unit"]
          @order_item.item_price = order_item["item_price"]
          @order_item.discount = order_item["discount"]
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
    def new
      @users = User.all
    end
    def edit
      @order = Order.find_by(id: params["id"])
      @orderitems = OrderItem.where(order_id: params["id"]).order(:sorting)
    end
    def deposit
      @order = Order.find_by(id: params["id"])
      @order.deposit = params["deposit"]
      @order.save
      render :text => "success"
    end
    def create
      new_order_params=order_params.except("supplier_name")
      @order = Order.new new_order_params
      @order.save
      @users = User.all
      redirect_to edit_order_path(@order.id)
    end
    def index
      if current_user.admin?
        @orders = Order.all 
      else
        @orders = Order.where("user_id = ?", current_user.id)
      end
    end
    def order_params
      params.require(:order).permit(:user_id, :supplier_name,:supplier_english_name,
        :supplier_address, :supplier_contact_person, :supplier_contact_no,:supplier_email, :marks, :supplier_id)
    end
    def header_values()
    end
    def init_doc_varibles()
      {
        sheets => {},
        content_styles => [],
        field_order = [],
        footer_values = [],
        footer_styles = [],
        header_length = 0,
        image_column = 0,
        col_range = template.first.merge_cells.first.ref.col_range
      }
    end
    def set_doc_varibles(vals,key,val)
      vals[key] = val
      vals
    end
    def order_xlsx
      @order = Order.find_by(id: params[:id])
        template = RubyXL::Parser.parse("public/system/spreadsheet/template/packing_template.xlsx")
require "byebug"; byebug
        p = Axlsx::Package.new
        order_book = p.workbook
        doc_varibles = init_doc_varibles 

        packing_list_book.styles do |s|
          horizontal_center_cell =  s.add_style  :alignment => { :horizontal=> :center }, :border => Axlsx::STYLE_THIN_BORDER
          top_border = s.add_style({:border => { :style => :thin, :color => 'FF000000',  :name => :top, :edges => [:top] }})
          top_left_right_border = s.add_style({:alignment => { :horizontal=> :center },:border => { :style => :thin, :color => 'FF000000',  :name => :top_left_right, :edges => [:top,:left,:right] }})
          top_right_border = s.add_style({:border => { :style => :thin, :color => 'FF000000',  :name => :top_right, :edges => [:top,:right] }})
          right_border = s.add_style({:border => { :style => :thin, :color => 'FF000000', :name => :right, :edges => [:right] }})
          bottom_border = s.add_style({:border => { :style => :thin, :color => 'FF000000', :name => :bottom, :edges => [:bottom] }})
          left_border = s.add_style({:border => { :style => :thin, :color => 'FF000000', :name => :left, :edges => [:left] }})

          packing_list_book.add_worksheet(:name => "Purchase Contract") do |sheet|          
            sheet.add_row ["利恩国际贸易有限公司","","","","","","","","","",""], :style => horizontal_center_cell, :types => [:string]
            sheet.rows.first.cells.each do |cell|
              cell.style = top_left_right_border
            end
            sheet.merge_cells("A1:L1")
            
            sheet.add_row ["Buyer:","", "LION INTERNATIONAL TRADING  CO.,LTD","","Supplier:","","","","",@order.supplier.supplier_name,"",""]
            sheet.merge_cells("A2:B2")
            sheet.merge_cells("C2:D2")
            sheet.merge_cells("E2:F2")
            sheet.merge_cells("G2:L2")

            sheet.add_row ["Address:","", "","","Supplier Address:","","","","",@order.supplier.supplier_address,"",""]
            sheet.merge_cells("A3:B3")
            sheet.merge_cells("C3:D3")
            sheet.merge_cells("E3:F3")
            sheet.merge_cells("G3:L3")

            sheet.add_row ["Buyer Contact:","","","","Supplier Contact:","","","","",@order.supplier.supplier_contact_person,"",""]
            sheet.merge_cells("A4:B4")
            sheet.merge_cells("C4:D4")
            sheet.merge_cells("E4:F4")
            sheet.merge_cells("G4:L4")

            sheet.add_row ["Buyer Contact No:","","","","Supplier Contact No:","","","","",@order.supplier.supplier_contact_no,"",""]
            sheet.merge_cells("A5:B5")
            sheet.merge_cells("C5:D5")
            sheet.merge_cells("E5:F5")
            sheet.merge_cells("G5:L5")

            sheet.add_row ["Buyer Contact Email:","","","","Supplier Contact Email:","","","","",@order.supplier.supplier_email,"",""]
            sheet.merge_cells("A6:B6")
            sheet.merge_cells("C6:D6")
            sheet.merge_cells("E6:F6")
            sheet.merge_cells("G6:L6")

            
            sheet['A2:A6'].each do |cell|
              cell.style = left_border
            end
            sheet['L2:L6'].each do |cell|
              cell.style = right_border
            end
            
            sheet.add_row ["PICTURE","PRODUCT NAME","SPECIFICATION","WEIGHT","QTY PER UNIT","UNIT","UNIT QTY","ITEM PRICE","PRICE SUB TOTAL","WEIGHT SUB TOTAL","CBM SUB TOTAL","REMARKS"], :style => Axlsx::STYLE_THIN_BORDER
            @orderitems = OrderItem.where(order_id: params["id"]).order(:sorting)
            @orderitems.each_with_index do |order_item, index|
              sheet.add_row ["", order_item.product_name,order_item.spec,
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
            sheet.add_row ["TOTAL","","","","","","=SUM(G8:G#{sheet.rows.length})","","=SUM(I8:I#{sheet.rows.length})","=SUM(J8:J#{sheet.rows.length})","=SUM(K8:K#{sheet.rows.length})",""], :style => horizontal_center_cell
            sheet.add_row ["","","","","","","","","","","Deposit Paid",@order.deposit], :style => horizontal_center_cell 
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
private
  def admin_only
    unless current_user.admin?
      redirect_to :back, :alert => "Access denied."
    end
  end
end
