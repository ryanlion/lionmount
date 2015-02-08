$(document).on('click','#add_row',function(){
  var i=$('#new-order-table >tbody >tr').length;
  $('#new-order-table > tbody:last').append('<tr id="addr'+(i+1)+'"></tr>');
  $('#addr'+(i+1)).html("<td><input class='row-selector' type='checkbox'/></td>"
    +"<td>"+ (i+1) +"</td>"
    + "<td><input name='order["+i+"][name]' type='text' placeholder='Name' class='form-control input-md'  /> </td>"
    + "<td><input  name='order["+i+"][picture]' type='file' class='form-control input-md'></td>"
    + "<td><input  name='order["+i+"][packing]' type='text' placeholder='packing'  class='form-control input-md'></td>");
});
$(document).on('click','#delete_row', function(){
  $('.row-selector:checkbox:checked').each(function () {
                                           
                                           $(this).closest("tr").remove();
  });
});
$(document).on('click','#save_order', function(){
               $form = $("#order-form");
               var jsondata = JSON.stringify($form.serializeJSON());
               var $this = $(this);
               var url = $this.data("rc-url");
               alert(url);
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
