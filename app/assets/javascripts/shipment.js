$(document).on('submit','#shipment-form', function(){
  $('.row-selector:checkbox:checked').each(function () {
                                           alert($(this).val());
    $(this).closest(".order-id").remove();
  });
               $("#shipment-form").submit();
});
