require_relative "../helpers/doc_helper"
class OrdersController < ApplicationController
  include DocHelper
    protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
    before_filter :admin_only, :except => [:index, :packing_list]
    def update
        order_items = params["order_items"]
        
        order_items.each_with_index do |order_item,i|
          @order_item = OrderItem.find_by(id: order_item["id"])
          @order_item.product_code = order_item["product_code"]
          @order_item.product_name = order_item["product_name"]
          @order_item.product_name_eng = order_item["product_name_eng"]
          @order_item.sorting = i+1
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
        @order.total_ctns = params["order_total_ctns"]
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
      @order.follower_id = current_user.id
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
    def init_doc_varibles(template)
      header_styles = []
      header_values = []
      header_images = []
      content_styles = []
      content_values = []
      footer_styles =[]
      footer_values = []
      image_column = 0
      template.first.each{|row|
        header_row_styles = []
        header_row_values = []
        content_row_styles = []
        content_row_values = []
        footer_row_styles = []
        footer_row_values = []
        row.cells.each{|cell|
          if row[0].value == "#HeaderRow#"
            if cell.value != "#HeaderRow#"
              header_row_styles << capture_style(cell)
              header_row_values << cell.value
              header_images << get_image_cell_info(template.first,cell) if cell.value && cell.value.include?("#image")
            end
          elsif row[0].value == "#ContentRow#"
            if cell.value != "#ContentRow#"
              content_styles << capture_style(cell)
              content_values << cell.value
              image_column = cell.column-1 if image_column == 0 && cell.value.include?("image_space") 
            end
          elsif row[0].value == "#FooterRow#"
            if cell.value != "#FooterRow#"
              footer_row_styles << capture_style(cell)
              footer_row_values << cell.value
            end
          end
        }
        if row[0].value == "#HeaderRow#"
          header_values << header_row_values 
          header_styles << header_row_styles
        elsif row[0].value == "#FooterRow#"
          footer_values << footer_row_values 
          footer_styles << footer_row_styles
        end
      }
      {
        "sheets" => {},
        "item_per_page" => 15,
        "header_styles" => header_styles,
        "header_values" => header_values,
        "header_images" => header_images,
        "header_heights" => get_row_heights(template.first,0,header_values.size),
        "header_merged_cells" => get_merged_cells(template.first,0,header_values.size),
        "content_styles" => content_styles,
        "content_values" => content_values,
        "content_heights" => get_row_heights(template.first,header_values.size,header_values.size),
        "footer_values" => footer_values,
        "footer_styles" => footer_styles,
        "footer_merged_cells" => get_merged_cells(template.first,header_values.size+1,header_values.size+1+footer_values.size),
        "footer_heights" => get_row_heights(template.first,header_values.size,header_values.size+1+footer_values.size),
        "image_column" => image_column,
        "max_col_no" => header_values.first.size,
        "column_widths" => get_column_widths(template.first,1,header_values.first.size)
      }
    end
     
    def order_xlsx
      @order = Order.find_by(id: params[:id])
        template = RubyXL::Parser.parse("public/system/spreadsheet/template/order_template.xlsx")
        p = Axlsx::Package.new
        p.use_autowidth = false
        order_book = p.workbook
        order_items = @order.order_items.sort_by &:sorting
        item_per_page = 15
        current_item_index = 1
        is_last_page = false
        order_sheets = create_sheets(order_book,item_per_page,order_items.size)
        doc_varibles = init_doc_varibles(template)
        page_ref = order_context_values(@order)
        order_sheets.each_with_index{|sheet,i|
          print_header(@order,sheet,doc_varibles,page_ref)
          set_column_widths(sheet,doc_varibles["column_widths"]) 
          merge_cells(sheet,doc_varibles["header_merged_cells"],0)
          offset = order_items[(i*item_per_page)..((i+1)*item_per_page-1)].size-1
          order_items[(i*item_per_page)..((i+1)*item_per_page-1)].each{|item|
            print_content(@order,sheet,doc_varibles,item)
            is_last_page = (current_item_index == order_items.size)
            current_item_index += 1
          }
          print_footer(@order,sheet,doc_varibles,page_ref,is_last_page)
          merge_cells(sheet,doc_varibles["footer_merged_cells"],offset)
          setup_page(sheet)
        }
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
