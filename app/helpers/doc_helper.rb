module DocHelper
  def order_context_values(order,customer,user,supplier)
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
      "supplier_name" => order.supplier.supplier_name,
      "supplier_contact_no" => order.supplier.supplier_contact_no,
      "image_space" => "",
      "product_code" => item.product_code,
      "prodect_name" => item.product_name,
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
      "image" => item.image.remote_url
    }
  end
  def capture_style(cell)
    {
      :fg_color => cell.font_color,
      :sz => cell.font_size.round,
      :font_name => cell.font_name,
      :border => { :color => 'FF000000', :style => :thin },
      :alignment => { :horizontal => h_alignment, :vertical => v_alignment },
      :b => cell.is_bolded.nil? ? false : cell.is_bolded
    }
  end
end
