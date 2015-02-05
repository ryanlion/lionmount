/*$(function () {
  $('#table-methods').next().click(function () {
    $(this).hide();

    var id = 0,
  getRows = function () {
    var rows = [];

    for (var i = 0; i < 10; i++) {
      rows.push({
        id: id,
        name: 'test' + id,
        price: '$' + id
      });
      id++;
    }
    return rows;
  },
  // init table use data
  $table = $('#table-methods-table').bootstrapTable({
    data: getRows()
  });

  $('#get-selections').click(function () {
    alert('Selected values: ' + JSON.stringify($table.bootstrapTable('getSelections')));
  });
  $('#get-data').click(function () {
    alert('current data: ' + JSON.stringify($table.bootstrapTable('getData')));
  });
  // This demonstrates utilizing the data-method attribute to use one 
  //     jQuery handler to execute multiple methods. 
  // ($this).data('method') retrieves the value of the data-method 
  //     attribute of the object that was clicked which is then passed to 
  //     the bootstrapTable function. 
  // Only the load and append methods require a parameter                                 
  $('#load-data, #append-data, #check-all, #uncheck-all, ' +
      '#show-loading, #hide-loading').click(function () {
        $table.bootstrapTable($(this).data('method'), getRows());
      });
  $('#refresh').click(function () {
    $table.bootstrapTable('refresh', {
      url: 'data1.json'
    });
  });
  $('#remove-data').click(function () {
    var selects = $table.bootstrapTable('getSelections');
    ids = $.map(selects, function (row) {
      return row.id;
    });

    $table.bootstrapTable('remove', {
      field: 'id',
      values: ids
    });
  });
  $('#update-row').click(function () {
    $table.bootstrapTable('updateRow', {
      index: 1,
      row: {
        name: 'test111111',
      price: '$111111'
      }
    });
  });
  $('#merge-cells').click(function () {
    $table.bootstrapTable('mergeCells', {
      index: 1,
      field: 'name',
      colspan: 2,
      rowspan: 3
    })
  });
  $('#show-column, #hide-column').click(function () {
    $table.bootstrapTable($(this).data('method'), 'id');
  });
  });
});*/
$(document).ready(function(){
  var i=$('#order-table >tbody >tr').length;
  $('#order-table > tbody:last').append('<tr id="addr'+(i+1)+'"></tr>');
  $("#add_row").click(function(){
    $('#addr'+i).html("<td>"+ (i+1) +"</td><td><input class='row-selector' type='checkbox'/>"
      + "<input name=order['"+i+"][name]' type='text' placeholder='Name' class='form-control input-md'  /> </td>
      + "<td><input  name='order["+i+"][picture]' type='file' class='form-control input-md'></td>"
      + "<td><input  name='order["+i+"][packing]' type='text' placeholder='packing'  class='form-control input-md'></td>");
  });
  $("#delete_row").click(function(){
      $(".row-selector").parentsUntil("tr").remove();
  });

});

