$(document).on('click','#add_row',function(){
  var itemUUID = uuid.v1({
      node: [0x01, 0x23, 0x45, 0x67, 0x89, 0xab],
      clockseq: 0x1234,
      msecs: new Date().getTime(),
      nsecs: 5678
  });
  var order_id = $('#order-id').val();
  $.ajax({
    url: 'orders/'+order_id+'/order_items',
    type: 'post',
    data: { 
      "uuid" : itemUUID
    },
    success: function(resp){
      var i=$('#edit-order-table >tbody >tr').length;
      $('#edit-order-table > tbody:last').append('<tr id="addr'+(i+1)+'"></tr>');
      $('#addr'+(i+1)).html("<td><input class='row-selector' type='checkbox'/></td>"
        +"<td>"+ (i+1) +"<input name='order_items["+i+"].itemUUID' type='hidden' class='uuid' value='"+itemUUID+"' >"
        +"<button type='button' class='btn btn-default btn-xs upload-icon' aria-label='Left Align'><span class='glyphicon glyphicon-folder-open' aria-hidden='true'></span></button>"
        +"<input name='order_items["+i+"].id' type='hidden' class='id' value='"+resp+"' ></td>"
        + "<td><input name='order_items["+i+"].product_name' type='text' placeholder='Name' class='form-control input-md'  /> </td>"
        + "<td class='img-td'></td>"
        + "<td><input  name='order_items["+i+"].packing' type='text' placeholder='packing'  class='form-control input-md'></td>");
    },
    error: function(resp){
      alert(resp);
    }

  });
  
});
$(document).on('click','#delete_row', function(){
  $('.row-selector:checkbox:checked').each(function () {
    $(this).closest("tr").remove();
  });
});
$(document).on('click','#save_order', function(){
  var obj = form2js(document.getelementbyid('order-form'));
  var jsondata = json.stringify(obj);
  var $this = $(this);
  var url = $this.data("rc-url");
  $.ajax({
    url: url,
    type: 'post',
    data: jsondata,
    success: function(html){
      alert(html);
    },
    error: function(resp){
      alert(resp);
    }

  });
});
$(document).on("change", ".file-upload", function () {
  var uuid = $(this).closest("tr").find(".uuid").val();
  var order_item_id = $(this).closest("tr").find(".id").val();
  var fileEleId = $(this).attr('id');
  var file = document.getElementById(fileEleId);
  var formData = new FormData();
  formData.append("opmlFile", file);
  formData.append("uuid",uuid);
  var order_id = $('#order-id').val();
  $.ajax({
    url: "/orders/"+order_id+"/order_items/"+order_item_id+"/upload_pic",
    type: "POST",
    data: formData,
    cache: false,
    contentType: false,
    processData: false
  })
  .error(function (xhr, status, error) {
    $.notify(error, true);
  })
  .success(function (data, status, xhr) {
    $.notify("Success");
  });
});
$(document).on('click','.upload-icon', function(){
  var uuid = $(this).closest("tr").find(".uuid").val();
  var order_item_id = $(this).closest("tr").find(".id").val();
  $("#order_item_id").val(order_item_id);
  $('#myModal').modal({
    keyboard: true
  });
}); 
