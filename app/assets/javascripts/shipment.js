$(document).on('click','.row-selector-shipment', function(){
  $this = $(this);
  $orderId = $this.next('.order-id')
  $shipmentUuid = $orderId.next('.shipment-uuid')
  if($this.is(":checked")){
    $this.next('.order-id').attr('name','selected_id[]');
    $orderId.attr('name','selected[]order_id');
    $shipmentUuid.attr('name','selected[]shipment_uuid');
  }else{
    $orderId.attr('name','not_selected[]order_id');
    $shipmentUuid.attr('name','not_selected[]shipment_uuid');
  }
});
$(document).on('submit','#shipment-form',function(){
  var new_uuid = uuid.v1({
    node: [0x01, 0x23, 0x45, 0x67, 0x89, 0xab],
      clockseq: 0x1234,
      msecs: new Date().getTime(),
      nsecs: 5678
  });
  alert($(".ship-uuid").val());
  $(".ship-uuid").val(new_uuid);
});
