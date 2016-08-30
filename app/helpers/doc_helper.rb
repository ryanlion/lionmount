module DocHelper
  def order_context_values(order)
    customer = order.user
    user = order.follower
    supplier = order.supplier
    {
      "customer" => customer.name,
      "order_id" => order.id,
      "order_marks" => order.marks,
      "order_deposit" => order.deposit,
      "order_date" => order.created_at,
      "order_delivery_date" => "",#order.delivery_date,
      "customer_contact_no" => user.contact_no,
      "customer_fax" => user.fax,
      "customer_address" => user.address,
      "customer_email" => user.email,
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
  def capture_style(cell)
    h_alignment = cell.horizontal_alignment.to_sym rescue :center
    v_alignment = cell.vertical_alignment.to_sym rescue :center
    {
      :fg_color => cell.font_color,
      :sz => cell.font_size.round,
      :font_name => cell.font_name,
      :border => { :color => 'FF000000', :style => :thin },
      :alignment => { :horizontal => h_alignment, :vertical => v_alignment },
      :b => cell.is_bolded.nil? ? false : cell.is_bolded
    }
  end
  def get_column_widths(sheet,start_column,end_column)
    
  end
  def get_merged_cells(sheet,start_row,end_row)
    merged_cells = sheet.merged_cells.map{|m_c| { "col_range" => m_c.ref.col_range, "row_range" => m_c.ref.row_range}}
    merged_cells = merged_cells.select{|c| c["row_range"].first >= start_row && c["row_range"].last < end_row}
    merged_cells
  end
  def merge_cells(sheet,merged_cells)
    merged_cells.each{|cell|
      sheet.merge_cells("#{to_alphabet(cell["col_range"].first)}#{cell["row_range"].first+1}:#{to_alphabet(cell["col_range"].last)}#{cell["row_range"].last+1}")
    }
  end
  def print_header(order,sheet,doc_varibles,header_ref)
    doc_varibles["header_values"].each_with_index{|header_row,i|
      values = header_row.map{|cell|
        val = (cell.nil? ? nil : cell.tr('\"',""))
        (header_ref[val].nil? ? cell : header_value[val])
      } 
      styles = doc_varibles["header_styles"][i].map{|s| sheet.styles.add_style(s)}
      sheet.add_row values, :style => styles
    } 
  end
  
  def print_content(p_obj,sheet,doc_varibles,item)
    ref=doc_varibles["content_values"].map{|v| v.tr('"',"")}
    values = order_item_values(p_obj,item)
    picked_values = ref.map{|r| values[r]}
    styles =  doc_varibles["content_styles"].map{|s| sheet.styles.add_style(s)}
    sheet.add_row picked_values, :style => styles 
    row_no = sheet.rows.length

    unless values["image"].nil? || values["image"].blank? then
      img = File.expand_path("#{Rails.root}/public#{values["image"]}", __FILE__)
      sheet.add_image(:image_src => img, :noSelect => false, :noMove => false) do |image|
        image.width=100
        image.height=66
        image.start_at doc_varibles["image_column"], row_no-1
      end
    else
      sheet.merge_cells("#{to_alphabet(doc_varibles["image_column"])}#{row_no}:#{to_alphabet(doc_varibles["image_column"])}#{row_no-1}")
    end
  end 
  def print_footer(order,sheet,doc_varibles,footer_ref) 
    doc_varibles["footer_values"].each_with_index{|footer_row,i|
      values = footer_row.map{|cell|
        val = (cell.nil? ? nil : cell.tr('\"',""))
        (footer_ref[val].nil? ? cell : footer_value[val])
      } 
      styles = doc_varibles["footer_styles"][i].map{|s| sheet.styles.add_style(s)}
      sheet.add_row values, :style => styles
    } 
  end
end
