var SalesOrderList = function(){
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

    /*************** Confirm Action *******************************/
    $('.sales-order-confirm').click(function(){
      var reqUrl = '/sales_orders/' + $(this).data('id') + '/update_status?save_action=confirm'
      var sales_order_id = $(this).data('id');
      var sales_order_token = $(this).data('token');
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.Result == "OK"){
            $('#sales_order_status_' + sales_order_id).html('<span class="label label-info">CONFIRMED</span>');
            $('.order_cancel_section_' + sales_order_id).show();
            $('.order_confirm_section_' + sales_order_id).hide();
            new PNotify({
              title: 'Success!',
              text: 'Sales Order ' + sales_order_token + ' is confirmed.',
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

    /*************** Cancel Action *******************************/
    $('.sales-order-cancel').click(function(){
      var reqUrl = '/sales_orders/' + $(this).data('id') + '/cancel'
      var sales_order_id = $(this).data('id');
      var sales_order_token = $(this).data('token');
      if(!confirm('Are you sure?')){
        return;
      }
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.Result == "OK"){
            $('#sales_order_status_' + sales_order_id).html('<span class="label label-danger">CANCELLED</span>');
            $('.order_confirm_section_' + sales_order_id).show();
            $('.order_cancel_section_' + sales_order_id).hide();
            new PNotify({
              title: 'Success!',
              text: 'Sales Order ' + sales_order_token + ' is cancelled.',
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

    /****************Package Action**************************/

    $('.package-sales-order').click(function(){
      var reqUrl = '/sales_orders/' + $(this).data('id') + '/package_detail_info';
      var type = $(this).data('type');
      $('#package_order_id').val($(this).data('id'));
      
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#package_customer_name').text(data.customer);
            $('#package_order_token').text(data.token);
            $('#package_req_url').val(data.package_req_url);
            var template = '';
            $.each( data.package_items, function( key, value ) {
              template += '<tr><td>'+value.sku+'</td>';
              template += '<td>'+value.name+'</td>';
              template += '<td>'+value.stock+'</td>';
              template += '<td>'+value.qty_to_package+'</td>';
              template += '<td class="editable" contentEditable="true">'+value.qty_to_package+'</td>';
              template += '<td class="editable" contentEditable="true"></td>';
              template += '<td style="display:none; ">'+value.id+'</td></tr>';
            });
            $('#product_list_body').html(template);

            if(data.total_qty_to_package > 0){
              $('#btn_create_package').show();
            } else {
              $('#btn_create_package').hide();
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

    $('#btn_create_package').click(function(){
      var packageItemData = new Array();
      $('#package_modal #product_list tbody tr').each(function(row, tr){
        packageItemData.push({
          "quantity" : $(tr).find('td:eq(4)').text().trim(),
          "note" :$(tr).find('td:eq(5)').text().trim(),
          "id" : $(tr).find('td:eq(6)').text().trim()
        });    
      }); 

      var reqUrl = $('#package_req_url').val();
      var data = {pack_attributes: packageItemData, id: $('#package_order_id').val()};
      do_activity(reqUrl, data);
    });

    /****************Package Modal Action**************************/

    $(document).on('focus', '#product_list td.editable', function(){
      $(this).addClass("edit-focus");
    });

    $(document).on('focusout', '#package_modal #product_list td.editable', function(){
      $("#package_modal #product_list td.editable").removeClass("edit-focus");
    });

    $(document).on('keydown', '#package_modal #product_list td.editable', function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
       event.preventDefault();
        break;
      }
    });    

    /*******************Shipment Action*****************************/
    $('.shipment-sales-order').click(function(){
      var reqUrl = '/sales_orders/' + $(this).data('id') + '/shipment_detail_info';
      var type = $(this).data('type');
      $('#shipment_order_id').val($(this).data('id'));
      $('#modal_tracking_number').val('');
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#shipment_customer_name').text(data.customer);
            $('#shipment_order_token').text(data.token);
            $('#shipment_method').text(data.shipment_method);
            $('#shipment_est_date').text(data.shipment_est_date);
            $('#shipment_req_url').val(data.shipment_req_url);
            var template = '';
            var prev_data = '';
            $.each( data.shipment_items, function( key, value ) {
              template += '<tr>';
              if (prev_data != value.token){
                template += '<td class="bulk_action" rowspan='+value.rowspan+'><input name="table_records" type="checkbox" value="'+ value.token +'"></td>';
                template += '<td rowspan='+value.rowspan+'>'+value.token+'</td>';
              }
              template += '<td>'+value.sku+'</td>';
              template += '<td>'+value.name+'</td>';
              template += '<td>'+value.created_date+'</td>';
              template += '<td>'+value.quantity+'</td>';
              template += '<td>'+value.note+'</td>';
              template += '<td>'+value.updater+'</td></tr>';
              prev_data = value.token;
            });
            $('#shipment_product_list_body').html(template);

            if(data.active_shipment){
              $('#btn_create_shipment').show();
            } else {
              $('#btn_create_shipment').hide();
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

    $("#shipment_modal #btn_create_shipment").click(function(){
      var records = [];
      $("#shipment_modal .bulk_action input[name='table_records']:checked").each(function() {
        records.push("'" + $(this).val() + "'");
      });

      var pack_tokens = '';

      if (records.length) {
        pack_tokens = records.join(",");
      } else {
        return;
      }

      var reqUrl = $('#shipment_req_url').val();
      var data = {pack_tokens: pack_tokens, id: $('#shipment_order_id').val(), track_number: $('#modal_tracking_number').val()};
      do_activity(reqUrl, data);
    });

    /********************Invoice Action*******************************************/

    $('.invoice-sales-order').click(function(){
      var reqUrl = '/sales_orders/' + $(this).data('id') + '/invoice_detail_info';
      var type = $(this).data('type');
      $('#invoice_order_id').val($(this).data('id'));
      
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#invoice_customer_name').text(data.customer);
            $('#invoice_customer_address').text(data.billing_address);
            $('#invoice_date').text('Date: ' + data.invoice_date);
            $('#invoice_customer_phone').text('Phone: ' + data.invoice_phone);
            $('#invoice_customer_fax').text('Fax: ' + data.invoice_fax);
            $('#invoice_sales_order_token').text('Sales Order: ' + data.token);
            $('#invoice_sales_order_booker').text('Processed By: ' + data.booker);

            $('#invoice_company_name').text(data.company_name);
            $('#invoice_company_address').text(data.company_address);
            $('#invoice_shipping_address').text(data.shipping_address);

            $('#invoice_req_url').val(data.invoice_req_url);
            $('#invoice_sub_total_cell').text(data.sub_total);
            $('#invoice_discount_total_cell').text(data.total_discount);
            $('#invoice_tax_total_cell').text(data.total_tax);
            $('#invoice_total_cell').text(data.total_amount);
            var template = '';
            $.each( data.invoice_items, function( key, value ) {
              template += '<tr><td>'+value.sku+'</td>';
              template += '<td>'+value.name+'</td>';
              template += '<td class="editable" contentEditable="true">'+value.quantity+'</td>';
              template += '<td>'+value.unit_price+'</td>';
              template += '<td>'+value.discount_rate+'</td>';
              template += '<td>'+value.tax_rate+'</td>';
              template += '<td>'+value.sub_total+'</td>';
              template += '<td style="display:none; ">'+value.id+'</td>';
              template += '<td style="display:none; ">'+value.type+'</td></tr>';
            });
            $('#invoice_product_list_body').html(template);
            
            if(data.status == 'quote'){
              $('#btn_create_invoice').hide();
            } else {
              $('#btn_create_invoice').show();
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
    $('#btn_create_invoice').click(function(){
      var invoiceItemData = new Array();
      $('#invoice_modal #product_list tbody tr').each(function(row, tr){
        invoiceItemData.push({
          "quantity" : $(tr).find('td:eq(2)').text().trim(),
          "discount" : $(tr).find('td:eq(4)').text().trim(),
          "tax" : $(tr).find('td:eq(5)').text().trim(),
          "sub_total" : $(tr).find('td:eq(6)').text().trim(),
          "id" : $(tr).find('td:eq(7)').text().trim(),
          "type" : $(tr).find('td:eq(8)').text().trim()
        });    
      }); 
      var reqUrl = $('#invoice_req_url').val();
      var data = {
          invoice_attributes: invoiceItemData, 
          // paid: $('#invoice_modal #paid_amount').val(),
          sub_total: $('#invoice_modal #invoice_sub_total_cell').text(),
          discount_total: $('#invoice_modal #invoice_discount_total_cell').text(),
          tax_total: $('#invoice_modal #invoice_tax_total_cell').text(),
          shipping_total: '0',
          total: $('#invoice_modal #invoice_total_cell').text()
      };
      do_activity(reqUrl, data);
    });    

    $(document).on('focusout', '#invoice_modal #product_list td.editable', function(){
      $("#invoice_modal #product_list td.editable").removeClass("edit-focus");
      calculateInvoice();
    });

    $(document).on('keydown', '#invoice_modal #product_list td.editable', function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateInvoice();
        event.preventDefault();
        break;
      }
    });

    function calculateInvoice(modalId = "#invoice_modal"){
      var subTotal = 0, 
          discountTotal = 0, 
          taxTotal = 0, 
          total = 0, 
          change = 0;        
      $( modalId + ' #product_list tbody tr').each(function(row, tr){
        var row_amount = 0;
        var quantity = $(tr).find('td:eq(2)').text().trim();
        var price = $(tr).find('td:eq(3)').text().trim();
        var discount = $(tr).find('td:eq(4)').text().trim();
        var tax = $(tr).find('td:eq(5)').text().trim();
        row_amount = quantity * price * (100 - discount) * 0.01;
        $(tr).find('td:eq(6)').text(row_amount.toFixed(2));

        row_amount = $(tr).find('td:eq(6)').text().trim();

        subTotal += (row_amount * 1);
        discountTotal += quantity * price * discount * 0.01;
        taxTotal += quantity * price * tax * 0.01;
        total += (row_amount * 1) + quantity * price * tax * 0.01;
      });

      var paid = 0;//$( modalId + ' #paid_amount').val();
      change = paid - total;
      $( modalId + ' #invoice_sub_total_cell').text(subTotal.toFixed(2));
      $( modalId + ' #invoice_discount_total_cell').text(discountTotal.toFixed(2));
      $( modalId + ' #invoice_tax_total_cell').text(taxTotal.toFixed(2));
      $( modalId + ' #invoice_total_cell').text(total.toFixed(2));
      $( modalId + ' #invoice_change_cell').text(change.toFixed(2));
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
          $('#sales_order_status_' + data.id).html('<span class="label ' + data.status_class + '">' + data.status_label+ '</span>');

          if(data.active_packed){
            $('#sales_order_row_' + data.id).find('td:eq(5) span').addClass('orange-status-active');
          } else {
            $('#sales_order_row_' + data.id).find('td:eq(5) span').removeClass('orange-status-active');
          }

          if(data.active_delivered){
            $('#sales_order_row_' + data.id).find('td:eq(6) span').addClass('blue-status-active');
          } else {
            $('#sales_order_row_' + data.id).find('td:eq(6) span').removeClass('blue-status-active');
          }

          if(data.active_invoiced){
            $('#sales_order_row_' + data.id).find('td:eq(7) span').addClass('white-blue-status-active');
          } else {
            $('#sales_order_row_' + data.id).find('td:eq(7) span').removeClass('white-blue-status-active');
          }

          if(data.active_fullfill){
            $('#sales_order_row_' + data.id).find('td:eq(8) span').addClass('green-status-active');
          } else {
            $('#sales_order_row_' + data.id).find('td:eq(8) span').removeClass('green-status-active');
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
    initSalesOrderList: function () {
      initialHeader();
      handleOrderBy();
      handleGroupSelect();
      handleOrderAction();
    }
  };
}();
