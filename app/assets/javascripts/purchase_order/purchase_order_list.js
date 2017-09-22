var PurchaseOrderList = function(){
  var initialHeader = function (){
    var order_key = $('#params').data('order');
    var order_sort = $('#params').data('sort');
    $('.link_order_by').each(function(){
      if($(this).data('key') == order_key){
        var html = '';
        if(order_sort == "desc"){
          $(this).data('sort', 'asc');
          html = '<i class="fa fa-icon fa-angle-down"></i>';
        } else {
          $(this).data('sort', 'desc');
          html = '<i class="fa fa-icon fa-angle-up"></i>';
        }
        $(this).append(html);
      }
    });
  }

  var handleOrderBy = function() {
    $('.link_order_by').click(function(){
      var searchKey = $('#params').data('key');
      if(searchKey){
        window.location.href='?order='+$(this).data('key')+'&sort='+$(this).data('sort') + '&key=' + searchKey;
      } else {
        window.location.href='?order='+$(this).data('key')+'&sort='+$(this).data('sort');
      }      
    });
  }

  var handleGroupSelect = function() {
    $('.group-checkable').click(function(){
      var parent_table = $(this).parents('table');
      if($(this).is(':checked') == true){
        parent_table.find(".bulk_action input[name='table_records']").prop("checked",true);
      } else {
        parent_table.find(".bulk_action input[name='table_records']").prop("checked",false);
      }
      $.uniform.update();
      //updateSelectedRecordLabel();
    });

    $(".bulk_action input[name='table_records']").click(function(){
      //updateSelectedRecordLabel();
    });

    $('#form_bulk_action').on('submit', function(){
      var records = [];
      $(".bulk_action input[name='table_records']:checked").each(function() {
          records.push($(this).val());
      });

      if (records.length) {
        $('#product_ids').val(records.join(","));
      } else {
        return false;
      }

    });
  }

  var handleOrderAction = function() {

    $('.receive-purchase-order').click(function(){
      var reqUrl = '/purchase_orders/' + $(this).data('id') + '/receive_detail_info';
      var type = $(this).data('type');
      $('#receive_order_id').val($(this).data('id'));

      if(type == 'receive'){
        $('#receive_modal_title').text('Purchase Order Receive');
        $('#btn_create_receive').text('Receive');
        $('#receive_modal_type').val('receive');
      } else {
        $('#receive_modal_title').text('Purchase Order Return');
        $('#btn_create_receive').text('Return');
        $('#receive_modal_type').val('return');
      }
      
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#receive_supplier_name').text(data.supplier);
            $('#receive_order_token').text(data.token);
            $('#receive_req_url').val(data.receive_req_url);
            $('#return_req_url').val(data.return_req_url);
            var template = '';
            $.each( data.receive_items, function( key, value ) {
              template += '<tr><td>'+value.sku+'</td>';
              template += '<td>'+value.name+'</td>';
              template += '<td>'+value.stock+'</td>';
              template += '<td>'+value.qty_to_receive+'</td>';
              if(type == 'receive'){
                template += '<td class="editable" contentEditable="true">'+value.qty_to_receive+'</td>';
              } else {
                template += '<td class="editable" contentEditable="true">0</td>';
              }
              template += '<td class="editable" contentEditable="true"></td>';
              template += '<td style="display:none; ">'+value.id+'</td></tr>';
            });
            $('#product_list_body').html(template);

            if(type == 'receive'){
              if(data.total_qty_to_receive > 0){
                $('#btn_create_receive').show();
              } else {
                $('#btn_create_receive').hide();
              }
            } else {
              if(data.total_received_qty > 0){
                $('#btn_create_receive').show();
              } else {
                $('#btn_create_receive').hide();
              }              
            }
          } else {
            new PNotify({
              title: 'Error!',
              text: data.Message,
              type: 'error',
              delay: 3000
            });              
          }
        },
        error:function(){
          new PNotify({
            title: 'Error!',
            text: 'Request is not processed.',
            type: 'error',
            delay: 3000
          });              
        }   
      });      
    });

    $('#btn_create_receive').click(function(){
      var receiveItemData = new Array();
      $('#receive_modal #product_list tbody tr').each(function(row, tr){
        receiveItemData.push({
          "quantity" : $(tr).find('td:eq(4)').text().trim(),
          "note" :$(tr).find('td:eq(5)').text().trim(),
          "id" : $(tr).find('td:eq(6)').text().trim()
        });    
      }); 

      if ($('#receive_modal_type').val() == 'receive'){
        var reqUrl = $('#receive_req_url').val();
        var data = {receive_attributes: receiveItemData, id: $('#receive_order_id').val()};
        do_activity(reqUrl, data);

      } else {
        var reqUrl = $('#return_req_url').val();
        var data = {return_attributes: receiveItemData, id: $('#receive_order_id').val()};
        do_activity(reqUrl, data);        
      }
    });

    /****************Receive Modal Action**************************/

    $(document).on('focus', '#receive_modal #product_list td.editable', function(){
      $(this).addClass("edit-focus");
    });

    $(document).on('focusout', '#receive_modal #product_list td.editable', function(){
      $("#receive_modal #product_list td.editable").removeClass("edit-focus");
    });

    $(document).on('keydown', '#receive_modal #product_list td.editable', function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
       event.preventDefault();
        break;
      }
    });    

    /***************************************************************/


    $('.purchase-order-approve').click(function(){
      var reqUrl = '/purchase_orders/' + $(this).data('id') + '/update_status?save_action=approve'
      var purchase_order_id = $(this).data('id');
      var purchase_order_token = $(this).data('token');
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.Result == "OK"){
            $('#purchase_order_status_' + purchase_order_id).html('<span class="label label-info">APPROVED</span>');
            $('.order_cancel_section_' + purchase_order_id).show();
            $('.order_approve_section_' + purchase_order_id).hide();
            new PNotify({
              title: 'Success!',
              text: 'Purchase Order ' + purchase_order_token + ' is approved.',
              type: 'success',
              delay: 3000
            });
          } else {
            new PNotify({
              title: 'Error!',
              text: data.Message,
              type: 'error',
              delay: 3000
            });              
          }
        },
        error:function(){
          new PNotify({
            title: 'Error!',
            text: 'Request is not processed.',
            type: 'error',
            delay: 3000
          });              
        }   
      });            
    });

    $('.purchase-order-cancel').click(function(){
      var reqUrl = '/purchase_orders/' + $(this).data('id') + '/cancel'
      var purchase_order_id = $(this).data('id');
      var purchase_order_token = $(this).data('token');
      if(!confirm('Are you sure?')){
        return;
      }
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.Result == "OK"){
            $('#purchase_order_status_' + purchase_order_id).html('<span class="label label-danger">CANCELLED</span>');
            $('.order_approve_section_' + purchase_order_id).show();
            $('.order_cancel_section_' + purchase_order_id).hide();
            new PNotify({
              title: 'Success!',
              text: 'Purchase Order ' + purchase_order_token + ' is cancelled.',
              type: 'success',
              delay: 3000
            });
          } else {
            new PNotify({
              title: 'Error!',
              text: data.Message,
              type: 'error',
              delay: 3000
            });              
          }
        },
        error:function(){
          new PNotify({
            title: 'Error!',
            text: 'Request is not processed.',
            type: 'error',
            delay: 3000
          });              
        }   
      });            
    });

    $('.bill-purchase-order').click(function(){
      var reqUrl = '/purchase_orders/' + $(this).data('id') + '/bill_detail_info';
      var type = $(this).data('type');
      $('#bill_order_id').val($(this).data('id'));
      
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#bill_supplier_name').text(data.supplier);
            $('#bill_supplier_address').text(data.billing_address);
            $('#bill_date').text('Date: ' + data.bill_date);
            $('#bill_supplier_phone').text('Phone: ' + data.bill_phone);
            $('#bill_supplier_fax').text('Fax: ' + data.bill_fax);
            $('#bill_purchase_order_token').text('Purchase Order: ' + data.token);
            $('#bill_purchase_order_booker').text('Processed By: ' + data.booker);

            $('#bill_req_url').val(data.bill_req_url);
            $('#bill_sub_total_cell').text(data.sub_total);
            $('#bill_tax_total_cell').text(data.total_tax);
            $('#bill_total_cell').text(data.total_amount);
            var template = '';
            $.each( data.bill_items, function( key, value ) {
              template += '<tr><td>'+value.sku+'</td>';
              template += '<td>'+value.name+'</td>';
              template += '<td class="editable" contentEditable="true">'+value.quantity+'</td>';
              template += '<td>'+value.unit_price+'</td>';
              template += '<td>'+value.tax_rate+'</td>';
              template += '<td>'+value.sub_total+'</td>';
              template += '<td style="display:none; ">'+value.id+'</td>';
              template += '<td style="display:none; ">'+value.type+'</td></tr>';
            });
            $('#bill_product_list_body').html(template);
            
            if(data.status == 'draft'){
              $('#btn_create_bill').hide();
            } else {
              $('#btn_create_bill').show();
            }

          } else {
            new PNotify({
              title: 'Error!',
              text: data.Message,
              type: 'error',
              delay: 3000
            });              
          }
        },
        error:function(){
          new PNotify({
            title: 'Error!',
            text: 'Request is not processed.',
            type: 'error',
            delay: 3000
          });              
        }   
      });      
    });

    /***********Bill Action*************/

    // Generate bill From Popup
    $('#btn_create_bill').click(function(){
      var billItemData = new Array();
      $('#bill_modal #product_list tbody tr').each(function(row, tr){
        billItemData.push({
          "quantity" : $(tr).find('td:eq(2)').text().trim(),
          "discount" : 0,
          "tax" : $(tr).find('td:eq(4)').text().trim(),
          "sub_total" : $(tr).find('td:eq(5)').text().trim(),
          "id" : $(tr).find('td:eq(6)').text().trim(),
          "type" : $(tr).find('td:eq(7)').text().trim()
        });    
      }); 
      var reqUrl = $('#bill_req_url').val();
      var data = {
          bill_attributes: billItemData, 
          // paid: $('#bill_modal #paid_amount').val(),
          sub_total: $('#bill_modal #bill_sub_total_cell').text(),
          discount_total: 0,
          tax_total: $('#bill_modal #bill_tax_total_cell').text(),
          shipping_total: '0',
          total: $('#bill_modal #bill_total_cell').text()
      };
      do_activity(reqUrl, data);
    });    

    $(document).on('focus', '#bill_modal #product_list td.editable', function(){
      $(this).addClass("edit-focus");
    });

    $(document).on('focusout', '#bill_modal #product_list td.editable', function(){
      $("#bill_modal #product_list td.editable").removeClass("edit-focus");
      calculateBill();
    });

    $(document).on('keydown', '#bill_modal #product_list td.editable', function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateBill();
        event.preventDefault();
        break;
      }
    });

    function calculateBill(modalId = "#bill_modal"){
      var subTotal = 0, 
          discountTotal = 0, 
          taxTotal = 0, 
          total = 0, 
          change = 0;        
      $( modalId + ' #product_list tbody tr').each(function(row, tr){
        var row_amount = 0;
        var quantity = $(tr).find('td:eq(2)').text().trim();
        var price = $(tr).find('td:eq(3)').text().trim();
        var discount = 0;
        var tax = $(tr).find('td:eq(4)').text().trim();
        row_amount = quantity * price;
        $(tr).find('td:eq(5)').text(row_amount.toFixed(2));

        row_amount = $(tr).find('td:eq(5)').text().trim();

        subTotal += (row_amount * 1);
        discountTotal = 0;
        taxTotal += quantity * price * tax * 0.01;
        total += (row_amount * 1) + quantity * price * tax * 0.01;
      });

      $( modalId + ' #bill_sub_total_cell').text(subTotal.toFixed(2));      
      $( modalId + ' #bill_tax_total_cell').text(taxTotal.toFixed(2));
      $( modalId + ' #bill_total_cell').text(total.toFixed(2));
    }
  }

  var do_activity = function(reqUrl, data, method = 'post'){
    $.ajax({
      url: reqUrl,
      type: method,
      datatype: 'json',
      data: data,
      success: function(data){
        if(data.Result == "OK"){
          $('#purchase_order_status_' + data.id).html('<span class="label ' + data.status_class + '">' + data.status_label+ '</span>');
          if(data.active_receive){
            $('#purchase_order_row_' + data.id).find('td:eq(5) span').addClass('orange-status-active');
          } else {
            $('#purchase_order_row_' + data.id).find('td:eq(5) span').removeClass('orange-status-active');
          }

          if(data.active_bill){
            $('#purchase_order_row_' + data.id).find('td:eq(6) span').addClass('green-status-active');
          } else {
            $('#purchase_order_row_' + data.id).find('td:eq(6) span').removeClass('green-status-active');
          }

          new PNotify({
            title: 'Success!',
            text: 'Action is done successfully.',
            type: 'success',
            delay: 3000
          });

        } else {
          new PNotify({
            title: 'Error!',
            text: data.Message,
            type: 'error'
          });              
        }
      },
      error:function(){
        new PNotify({
          title: 'Error!',
          text: 'Order request is not processed.',
          type: 'error'
        });              
      }   
    });
  }

  return {
    initPurchaseOrderList: function () {
      initialHeader();
      handleOrderBy();
      handleGroupSelect();
      handleOrderAction();
    }
  };
}();
