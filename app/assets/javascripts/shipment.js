$(document).on('submit','#shipment-form', function(){
  $('.row-selector:checkbox:checked').each(function () {
    $(this).closest("tr").remove();
  });
});
