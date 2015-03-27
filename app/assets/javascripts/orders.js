$(document).on('click','.show-pic',function(){
  var img = $(this).find('img');
  var tem_img = $('<img/>');
  var src = img.attr('src');
  tem_img.attr('src',src);
  tem_img.attr('width','250');
  tem_img.attr('height','168');

  var div = $('<div></div>');
  div.append(tem_img);
  html = div.html();
  $(this).popover({placement: 'right', trigger: 'click', content: html, html: true});
});
$(document).on('click','#delete_row', function(){
  var ids = "";
  $('.row-selector:checkbox:checked').each(function () {
    ids = ids + '"' +$(this).closest("tr").find(".id").val() + '"';
   	//$(this).closest("tr").remove();
  });
  ids = "["+ ids + "]";
	var order_id = $('#order-id').val();
	
  $.ajax({
    url: '/orders/'+order_id+'/order_items/delete_order_items',
    type: 'delete',
    data: { 
      "item_ids" : ids
    },
    success: function(resp){
	  $('.row-selector:checkbox:checked').each(function () {
	   	$(this).closest("tr").remove();
	  });    
    },
    error: function(resp){
      alert(resp);
    }

  });
});

$(document).on('click','#save_order', function(){
  var $this = $(this);
  var url = $this.data("rc-url");
  $.ajax({
    url: url,
    type: 'PUT',
    data: $("#order-form").serialize(),
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
