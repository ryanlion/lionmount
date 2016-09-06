module DocHelper
  def order_context_values(order)
    customer = order.user
    user = order.follower
    supplier = order.supplier
    {
      "customer" => customer.name,
      "follower" => user.name,
      "order_id" => order.id,
      "order_marks" => order.marks,
      "order_deposit" => order.deposit,
      "order_total_volume" => order.total_volume,
      "order_total_weight" => order.total_weight,
      "order_total_ctns" => order.total_ctns,
      "order_total_price" => order.total_price,
      "order_date" => order.created_at,
      "order_delivery_date" => "",#order.delivery_date,
      "customer_contact_no" => user.contact_no,
      "customer_fax" => customer.fax,
      "customer_address" => customer.address,
      "customer_email" => customer.email,
      "supplier_name" => supplier.supplier_name,
      "supplier_contact_no" => supplier.supplier_contact_no,
      "supplier_contact_person" => supplier.supplier_contact_person
    }
  end
  def to_alphabet(i)
    i.to_s(26).tr( "123456789abcdefghijklmnopqr", "abcdefghijklmnopqrstuvwxyz" ).upcase
  end
  def order_item_values(order,item)
    {
      "order_id" => item.order_id,
      "order_item_id" => item.sorting,
      "supplier_name" => order.supplier.supplier_name,
      "supplier_contact_no" => order.supplier.supplier_contact_no,
      "image_space" => "",
      "product_code" => item.product_code,
      "product_name" => item.product_name,
      "product_name_eng" => item.product_name_eng,
      "spec" => item.spec,
      "spec_eng" => item.spec_eng,
      "quantity_per_unit" => item.quantity_per_unit,
      "no_of_unit" => item.no_of_unit,
      "item_total_volume" => item.item_total_volume,
      "item_total_weight" => item.item_total_weight,
      "item_price" => item.item_price,
      "item_total_price" => item.item_total_price,
      "volume_per_unit" => item.volume_per_unit,
      "weight_per_unit" => item.weight_per_unit,
      "image" => (item.image.nil? ? "" : item.image.remote_url)
    }
  end
  def create_sheets(workbook,items_per_page,items_total)
    sum = 1
    sheets = []
    while sum < items_total
      sheets << workbook.add_worksheet(:name => "Order #{sum}-#{sum+items_per_page-1}")
      sum += items_per_page
    end
    sheets
  end
  def replace_values(val,val_ref)
    matched = /"([^\\"]|\\\\|\\")*"/.match(val)
    unless matched.nil?
      val.gsub(matched.to_s,val_ref[matched.to_s.tr('\"',"")].to_s) rescue val
    else
      val
    end
  end
  
  def replace_function_values(val,val_ref,is_last_page)
    matched = /{(.*?)}/.match(val)
    unless matched.nil?
      if is_last_page
        val.gsub(matched.to_s,val_ref[matched.to_s.tr('{}"',"")].to_s) rescue val
      else
        val.gsub(matched.to_s,"") rescue val
      end
    else
      val
    end
  end
  def capture_style(cell)
    h_alignment = cell.horizontal_alignment.to_sym rescue :center
    v_alignment = cell.vertical_alignment.to_sym rescue :center
    wrap_text = cell.text_wrap rescue false
    border={}
    unless cell.get_border(:top).nil? && cell.get_border(:bottom).nil? && cell.get_border(:left).nil? && cell.get_border(:right).nil?
      edges = []
      edges << :top unless cell.get_border(:top).nil?
      edges << :bottom unless cell.get_border(:bottom).nil?
      edges << :left unless cell.get_border(:left).nil?
      edges << :right unless cell.get_border(:right).nil?
      border = { :color => 'FF000000', :style => :thin, :edges => edges }
    else
      border = nil
    end
    {
      :fg_color => cell.font_color,
      :sz => cell.font_size.round,
      :font_name => cell.font_name,
      :border => border,
      :alignment => { :horizontal => h_alignment, :vertical => v_alignment, :wrap_text => wrap_text },
      :b => cell.is_bolded.nil? ? false : cell.is_bolded
    }
  end
  def get_row_heights(sheet,start_row,end_row)
    range = start_row..end_row
    heights = []
    range.each{|row_no|
      height = sheet.get_row_height(row_no)
      heights << height
    }
    heights
  end
  def get_column_widths(sheet,start_column,end_column)
    range = start_column..end_column
    widths = []
    range.each{|column_no|
      width = sheet.get_column_width(column_no)
      widths << width
    }
    widths
  end
  def set_column_widths(sheet,widths)
    widths.each_with_index{|w,i|
      sheet.column_info[i].width = w
    }
  end
  def get_image_cell_info(sheet,cell)
    #merged_img_cell_ref = sheet.merged_cells.select{|c| c.ref.col_range.first == cell.column && c.ref.row_range.first == cell.row }.first.ref
    #image_height = get_row_heights(sheet,merged_img_cell_ref.row_range.first,merged_img_cell_ref.row_range.last).reduce(:+)
    #image_width = get_column_widths(sheet,merged_img_cell_ref.col_range.first,merged_img_cell_ref.col_range.last).reduce(:+)
    image_path = nil, image_height = nil, image_width = nil, image_start_column = nil, image_start_row = nil
    if cell.value == "#image_logo#"
      settings = Settings.first
      image_path = "#{Rails.root}/public#{settings.site_logo.remote_url}"
      image_width = settings.order_logo_width
      image_height = settings.order_logo_height
      image_start_column = cell.column
      image_start_row = cell.row
    end
    {
      "image_name" => cell.value,
      #"image_range" => merged_img_cell_ref,
      "image_start_cell" => {"column" => image_start_column, "row" => image_start_row },
      "image_height" => image_height,
      "image_width" => image_width,
      "image_path" => image_path
    }
  end
  def get_merged_cells(sheet,start_row,end_row)
    merged_cells = sheet.merged_cells.map{|m_c| { "col_range" => m_c.ref.col_range, "row_range" => m_c.ref.row_range}}
    merged_cells = merged_cells.select{|c| c["row_range"].first >= start_row && c["row_range"].last < end_row}
    merged_cells
  end
  def merge_cells(sheet,merged_cells,offset)
    merged_cells.each{|cell|
      sheet.merge_cells("#{to_alphabet(cell["col_range"].first)}#{cell["row_range"].first+1+offset}:#{to_alphabet(cell["col_range"].last)}#{cell["row_range"].last+1+offset}")
    }
  end
  def setup_page(sheet)
    #options = {
    #    :margins => {:left => 0, :right => 0, :top => 0, :bottom => 0, :header => 0, :footer => 0 },
    #    :setup => { :orientation => :portrait, :paper_size => 12, :paper_width => "245mm", :paper_height => "350mm"},
    #    :options => {:grid_lines => false, :headings => false, :horizontal_centered => true}
    #  }
    #sheet.page_setup.set(options)
    sheet.print_options.vertical_centered = true
    sheet.print_options.horizontal_centered = true
    sheet.page_margins.left = 0.2
    sheet.page_margins.right = 0.3
    sheet.page_margins.top = 0.1
    sheet.page_margins.bottom = 0.1
    sheet.page_margins.header = 0.1
    sheet.page_margins.footer = 0.1
    sheet.page_setup.scale = 65
    sheet.page_setup.orientation = :portrait
    sheet.page_setup.paper_height = "50mm"
    sheet.page_setup.fit_to :height => 1
  end
  def print_header(order,sheet,doc_varibles,header_ref)
    doc_varibles["header_values"].each_with_index{|header_row,i|
      values = header_row.map{|cell|
        if !cell.nil? && cell == doc_varibles["header_images"].first["image_name"]
          print_image(sheet,doc_varibles["header_images"].first)
          nil
        else
          (cell.nil? ? nil : replace_values(cell,header_ref))
        end
      } 
      styles = doc_varibles["header_styles"][i].map{|s| sheet.styles.add_style(s)}
      sheet.add_row values, :style => styles, :height => doc_varibles["header_heights"][i]
    } 
  end
  
  def print_content(p_obj,sheet,doc_varibles,item)
    ref=doc_varibles["content_values"].map{|v| v.tr('"',"")}
    values = order_item_values(p_obj,item)
    picked_values = ref.map{|r| values[r]}
    styles = doc_varibles["content_styles"].map{|s| sheet.styles.add_style(s)}
    sheet.add_row picked_values, :style => styles, :height => doc_varibles["content_heights"].first 
    row_no = sheet.rows.length

    unless values["image"].nil? || values["image"].blank? then
      img = File.expand_path("#{Rails.root}/public#{values["image"]}", __FILE__)
      sheet.add_image(:image_src => img, :noSelect => false, :noMove => false) do |image|
        image.width=66
        image.height=44
        image.start_at doc_varibles["image_column"], row_no-1
      end
    else
      sheet.merge_cells("#{to_alphabet(doc_varibles["image_column"])}#{row_no}:#{to_alphabet(doc_varibles["image_column"])}#{row_no-1}")
    end
  end 
  def print_footer(order,sheet,doc_varibles,footer_ref,is_last_page) 
    doc_varibles["footer_values"].each_with_index{|footer_row,i|
      values = footer_row.map{|cell|
        tem_val = (cell.nil? ? nil : replace_values(cell,footer_ref))
        replace_function_values(tem_val,footer_ref,is_last_page)
      } 
      styles = doc_varibles["footer_styles"][i].map{|s| sheet.styles.add_style(s)}
      sheet.add_row values, :style => styles, :height => doc_varibles["header_heights"][i]
    } 
  end
  
  def print_image(sheet,image_info)
    img = image_info["image_path"]
    sheet.add_image(:image_src => img, :noSelect => false, :noMove => false) do |image|
      image.width= image_info["image_width"]
      image.height= image_info["image_height"]
      image.start_at image_info["image_start_cell"]["column"]-1,image_info["image_start_cell"]["row"]#image_info["image_range"].row_range.first+1, image_info["image_range"].col_range.first
      #image.end_at 2,2#image_info["image_range"].row_range.last+1, image_info["image_range"].col_range.last
    end
  end
end
