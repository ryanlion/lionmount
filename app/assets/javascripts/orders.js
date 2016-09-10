$(document).on('change','.no_of_unit', function () {
  calculateWeight(this);
  calculateVolume(this);
  calculateAmount(this);
});
$(document).on('change','.weight_per_unit', function () {
  calculateWeight(this);
});
$(document).on('change','.volume_per_unit', function () {
  calculateVolume(this);
});

$(document).on('change','.quantity_per_unit', function () {
  calculateAmount(this);
});
$(document).on('change','.item_price', function () {
  calculateAmount(this);
});
function calculateWeight(obj){
  if(!$(obj).closest("tr").find(".no_of_unit").val() || $(obj).closest("tr").find(".no_of_unit").val()=="")  return; 
  if(!$(obj).closest("tr").find(".weight_per_unit").val() || $(obj).closest("tr").find(".weight_per_unit").val()=="")  return; 

  var no_of_unit = $(obj).closest("tr").find(".no_of_unit").val();
  var weight_per_unit = $(obj).closest("tr").find(".weight_per_unit").val();
  var item_total_weight = parseFloat(weight_per_unit)*parseFloat(no_of_unit);
  $(obj).closest("tr").find(".item_total_weight").val(precise_round(item_total_weight,2)); 
}
function calculateVolume(obj){
  if(!$(obj).closest("tr").find(".no_of_unit").val() || $(obj).closest("tr").find(".no_of_unit").val()=="")  return; 
  if(!$(obj).closest("tr").find(".volume_per_unit").val() || $(obj).closest("tr").find(".volume_per_unit").val()=="")  return; 

  var no_of_unit = $(obj).closest("tr").find(".no_of_unit").val();
  var volume_per_unit = $(obj).closest("tr").find(".volume_per_unit").val();
  var item_total_volume = parseFloat(volume_per_unit)*parseFloat(no_of_unit);
  $(obj).closest("tr").find(".item_total_volume").val(precise_round(item_total_volume,2)); 
}
function calculateAmount(obj){
  if(!$(obj).closest("tr").find(".no_of_unit").val() || $(obj).closest("tr").find(".no_of_unit").val()=="")  return; 
  if(!$(obj).closest("tr").find(".item_price").val() || $(obj).closest("tr").find(".item_price").val()=="")  return; 
  if(!$(obj).closest("tr").find(".quantity_per_unit").val() || $(obj).closest("tr").find(".quantity_per_unit").val()=="")  return; 
  var no_of_unit = $(obj).closest("tr").find(".no_of_unit").val();
  var item_price = $(obj).closest("tr").find(".item_price").val();
  var quantity_per_unit = $(obj).closest("tr").find(".quantity_per_unit").val();
  var amount = parseFloat(item_price)*parseFloat(quantity_per_unit)*parseFloat(no_of_unit);
  $(obj).closest("tr").find(".item_total_price").val(precise_round(amount,2)); 
}

//calculate sum
$(document).on('change','body', function () {
  var total_price = 0.0;
  var total_weight = 0.0;
  var total_volume = 0.0;
  var total_ctns = 0;
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
  $('.no_of_unit').each(function () {
    if($(this).val() != ''){
      var item_total_ctns = parseInt($(this).val());
      total_ctns = total_ctns + item_total_ctns;
    }
  });
  $('.order_total_price').html(precise_round(total_price,2));
  $('.order_total_weight').html(precise_round(total_weight,2));
  $('.order_total_volume').html(precise_round(total_volume,2));
  $('.order_total_ctns').html(total_ctns);
  $('#order_total_price').val(precise_round(total_price,2));
  $('#order_total_weight').val(precise_round(total_weight,2));
  $('#order_total_volume').val(precise_round(total_volume,2));
  $('#order_total_ctns').val(total_ctns);
});

var baidu_appid = "20160614000023334";
var baidu_key = "uQbKAdDCOjqyclN3hRRf";

$(document).on('ready page:load', function () {
	$('td').addClass( "nopadding" );
	$('.parsley-errors-list').addClass( "nopadding" );
});
$(document).on('change','.product_name', function () {
  translate($(this),$(this).closest("tr").find(".product_name_eng"));
});
$(document).on('change','.product_spec', function () {
  translate($(this),$(this).closest("tr").find(".product_spec_eng"));
});
function translate(source_obj, target_obj){
  var random = Math.floor((Math.random() * 100000000000) + 1);
  var source = $(source_obj).val().replace(/\n/g,"<br>");
  var sign = baidu_appid + source + random + baidu_key; 
  var sign_md5 = $.md5(sign);
  //var url = "http://api.fanyi.baidu.com/api/trans/vip/translate?"+"q="+ source + "&from=zh&to=en&appid=" + baidu_appid + "&salt="+ random + "&sign="+ sign_md5;
  var url = "//api.fanyi.baidu.com/api/trans/vip/translate?"+"q="+ source + "&from=zh&to=en&appid=" + baidu_appid + "&salt="+ random + "&sign="+ sign_md5;
  $.ajax({
    url: url,
    type: 'GET',
    crossDomain: true,
    dataType: 'jsonp',
    headers: {"Access-Control-Allow-Origin": "*"},
    success: function(resp){
      $(target_obj).val(resp.trans_result[0].dst.replace(/\<br\>/g,"\n"));
    },
    error: function(resp){
      alert('error');
    }

  });

}

$(document).on('click','#language',function(){
  if($(this).html() == "Show English"){
    $('.product_name_eng').show();
    $('.product_spec_eng').show();
    $(this).html("Hide English");
  } else {
    $('.product_name_eng').hide();
    $('.product_spec_eng').hide();
    $(this).html("Show English");
  }
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
	   	$('.sorting').each(function(index) {
	      $(this).val(index+1);
	      $(this).closest('tr').find('.sorting_text').html(index+1);
	    });
	  	$("#save_order_invisible").click();
	  });
    },
    error: function(resp){
      alert('error');
    }

  });
});
$(document).on('click','.supplier-table tr td', function(){
  $checkbox = $(this).find('.row-selector');
  if($checkbox.prop("checked")){
  	$checkbox.prop("checked",false);
        $("#supplier_id").val("");
        $("#create_order").prop("disabled", false);
  }else{
  	$checkbox.prop("checked",true);
        $("#supplier_id").val($(this).find(".supplier_id").val());
        $("#create_order").removeAttr('disabled');;
  }
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
$(document).on('load','#supplier-table', function(){
  $('.row-selector').unbind('click');
});
$(document).on('click','.row-selector', function(e){
  e.preventDefault();
});
$(document).on('click','.moverow', function(){
  var rowno = $('#rowno').val();
  rowno = parseInt(rowno);
  var rowtomove=$('#edit-order-table tr:eq('+ rowno +')');
  $('.row-selector:checkbox:checked').each(function () {
    var row = $(this).closest("tr");
    row.insertAfter(rowtomove);
  });
  $('.sorting').each(function(index) {
    $(this).val(index+1);
    $(this).closest('tr').find('.sorting_text').html(index+1);
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
$(document).on("keyup", ".supplier_code", function () {
  $.ajax({
    url: "/suppliers/find_suppliers?supplier_code="+$(this).val(),
    type: "GET"
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
$(document).on('change','#deposit', function(){
	var order_id = $('#order-id').val();
  var deposit = $(this).val();
  $.ajax({
    url: '/orders/'+order_id+'/deposit',
    type: 'post',
    data: { 
      "deposit" : deposit
    },
    success: function(resp){

    },
    error: function(resp){
      alert('error');
    }

  });
});

function precise_round(num,decimals){
return Math.round(num*Math.pow(10,decimals))/Math.pow(10,decimals);
}
