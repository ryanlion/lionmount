//weight per unit
$(document).on('change','.product_weight', function () {
	var quantity_per_unit = $(this).closest("tr").find(".quantity_per_unit").val();
	var weight_per_unit = parseFloat($(this).val())*parseFloat(quantity_per_unit);
	$(this).closest("tr").find(".weight_per_unit").val(precise_round(weight_per_unit,2));
});
$(document).on('change','.quantity_per_unit', function () {
	var product_weight = $(this).closest("tr").find(".product_weight").val();
	var weight_per_unit = parseFloat($(this).val())*parseFloat(product_weight);
	$(this).closest("tr").find(".weight_per_unit").val(precise_round(weight_per_unit,2));
});

//item total price 
$(document).on('change','.quantity_per_unit', function () {
	var no_of_unit = $(this).closest("tr").find(".no_of_unit").val();
	var item_price = $(this).closest("tr").find(".item_price").val();
	var item_total_price = parseFloat($(this).val())*parseFloat(no_of_unit)*parseFloat(item_price);
	$(this).closest("tr").find(".item_total_price").val(precise_round(item_total_price,2));
});
$(document).on('change','.item_price', function () {
	var quantity_per_unit = $(this).closest("tr").find(".quantity_per_unit").val();
	var no_of_unit = $(this).closest("tr").find(".no_of_unit").val();
	var item_total_price = parseFloat($(this).val())*parseFloat(quantity_per_unit)*parseFloat(no_of_unit);
	$(this).closest("tr").find(".item_total_price").val(precise_round(item_total_price,2));
});
$(document).on('change','.no_of_unit', function () {
	var quantity_per_unit = $(this).closest("tr").find(".quantity_per_unit").val();
	var item_price = $(this).closest("tr").find(".item_price").val();
	var item_total_price = parseFloat($(this).val())*parseFloat(quantity_per_unit)*parseFloat(item_price);
	$(this).closest("tr").find(".item_total_price").val(precise_round(item_total_price,2));
});

//item total weight
$(document).on('change','.quantity_per_unit', function () {
	var no_of_unit = $(this).closest("tr").find(".no_of_unit").val();
	var product_weight = $(this).closest("tr").find(".product_weight").val();
	var item_total_weight = parseFloat($(this).val())*parseFloat(no_of_unit)*parseFloat(product_weight);
	$(this).closest("tr").find(".item_total_weight").val(precise_round(item_total_weight,2));
});
$(document).on('change','.product_weight', function () {
	var quantity_per_unit = $(this).closest("tr").find(".quantity_per_unit").val();
	var no_of_unit = $(this).closest("tr").find(".no_of_unit").val();
	var item_total_weight = parseFloat($(this).val())*parseFloat(no_of_unit)*parseFloat(quantity_per_unit);
	$(this).closest("tr").find(".item_total_weight").val(precise_round(item_total_weight,2));
});
$(document).on('change','.no_of_unit', function () {
	var quantity_per_unit = $(this).closest("tr").find(".quantity_per_unit").val();
	var product_weight = $(this).closest("tr").find(".product_weight").val();
	var item_total_weight = parseFloat($(this).val())*parseFloat(quantity_per_unit)*parseFloat(product_weight);
	$(this).closest("tr").find(".item_total_weight").val(precise_round(item_total_weight,2));
});
//volume per item
$(document).on('change','.volume_per_unit', function () {
	var no_of_unit = $(this).closest("tr").find(".no_of_unit").val();
	var item_total_volume = parseFloat($(this).val())*parseFloat(no_of_unit);
	$(this).closest("tr").find(".item_total_volume").val(precise_round(item_total_volume,2));
});
$(document).on('change','.no_of_unit', function () {
	var volume_per_unit = $(this).closest("tr").find(".volume_per_unit").val();
	var item_total_volume = parseFloat($(this).val())*parseFloat(volume_per_unit);
	$(this).closest("tr").find(".item_total_volume").val(precise_round(item_total_volume,2));
});

//calculate sum
$(document).on('change','body', function () {
  var total_price = 0.0;
  var total_weight = 0.0;
  var total_volume = 0.0;
	$('.item_total_price').each(function () {
    if($(this).val() != ''){
      var item_total_price = parseFloat($(this).val());
      total_price = total_price + item_total_price;
    }
  });
	$('.item_total_weight').each(function () {
    if($(this).val() != ''){
      var item_total_weight = parseFloat($(this).val());
      total_weight = total_weight + item_total_weight;
    }
  });
	$('.item_total_volume').each(function () {
    if($(this).val() != ''){
      var item_total_volume = parseFloat($(this).val());
      total_volume = total_volume + item_total_volume;
    }
  });
  $('.order_total_price').html(precise_round(total_price,2));
  $('.order_total_weight').html(precise_round(total_weight,2));
  $('.order_total_volume').html(precise_round(total_volume,2));
  $('#order_total_price').val(precise_round(total_price,2));
  $('#order_total_weight').val(precise_round(total_weight,2));
  $('#order_total_volume').val(precise_round(total_volume,2));
});








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
    ids = ids + '"' +$(this).closest("tr").find(".id").val() + '",';
  });
  ids = '{"idarr":['+ ids.substring(0,ids.length-1) + ']}';
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
      alert('error');
    }

  });
});
$(document).on('click','#edit-order-table tr td', function(){
  $checkbox = $(this).find('.row-selector');
  if($checkbox.prop("checked")){
  	$checkbox.prop("checked",false);
  }else{
  	$checkbox.prop("checked",true);
  }
});
$(document).on('load','#edit-order-table', function(){
  $('.row-selector').unbind('click');
});
$(document).on('click','.row-selector', function(e){
  e.preventDefault();
});
$(document).on('click','.moverow', function(){
  var rowno = $('#rowno').val();
  $('.row-selector:checkbox:checked').each(function () {
    rowno = parseInt(rowno) + 1;
    var rowtomove=$('#edit-order-table tr:eq('+ rowno +')');
    var row = $(this).closest("tr");
    row.insertAfter(rowtomove);
  });
  $('.sorting').each(function(index) {
    $(this).val(index);
    $(this).closest('tr').find('.sorting_text').html(index);
  });
  $('#save_order_invisible').click();
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
$(document).on('click','#save_order_invisible', function(){
  var $this = $(this);
  var url = $this.data("rc-url");
  $.ajax({
    url: url,
    type: 'PUT',
    data: $("#order-form").serialize(),
    success: function(html){
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


function precise_round(num,decimals){
return Math.round(num*Math.pow(10,decimals))/Math.pow(10,decimals);
}
