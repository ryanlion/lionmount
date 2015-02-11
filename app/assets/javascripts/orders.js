$(document).on('click','#add_row',function(){
  var itemUUID = uuid.v1({
      node: [0x01, 0x23, 0x45, 0x67, 0x89, 0xab],
      clockseq: 0x1234,
      msecs: new Date().getTime(),
      nsecs: 5678
  });
  var i=$('#edit-order-table >tbody >tr').length;
  $('#edit-order-table > tbody:last').append('<tr id="addr'+(i+1)+'"></tr>');
  $('#addr'+(i+1)).html("<td><input class='row-selector' type='checkbox'/></td>"
    +"<td>"+ (i+1) +"<input name='order_items["+i+"].itemUUID' type='hidden' value='"+itemUUID+"' ></td>"
    + "<td><input name='order_items["+i+"].product_name' type='text' placeholder='Name' class='form-control input-md'  /> </td>"
    + "<td><input  name='order_items["+i+"].picture' type='file' class='form-control input-md file-upload'></td>"
    + "<td><input  name='order_items["+i+"].packing' type='text' placeholder='packing'  class='form-control input-md'></td>");
});
$(document).on('click','#delete_row', function(){
  $('.row-selector:checkbox:checked').each(function () {
                                           
                                           $(this).closest("tr").remove();
  });
});
$(document).on('click','#save_order', function(){
               var obj = form2js(document.getElementById('order-form'));
               var jsondata = JSON.stringify(obj);
               var $this = $(this);
               var url = $this.data("rc-url");
               $.ajax({
                      url: url,
                      type: 'POST',
                      data: jsondata,
                      success: function(html){
                      alert(html);
                      },
                      error: function(resp){
                      alert(resp);
                      }
                      
                      });
});
$('.file-upload').simpleUpload({
        url: '',
        change: function(files){
            $.each(files, function(i, file){
    alert(1);            });
        }
    });
