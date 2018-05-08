
var SalesOrderDetail = function () {
  var initialNavigatorList = function(){    
    $('#order_side_menu').mCustomScrollbar({theme:"minimal-dark", scrollbarPosition: "outside"});    

    var active_elem = 'li.' + $('#active_elem').data('elem') + ' a';
    $(active_elem).addClass('nav-active');    
    $('#order_side_menu').mCustomScrollbar("scrollTo", active_elem);
  }

  var handlePackageTab = function() {
    $("#tab_pack #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#tab_pack #product_list td.editable").focusout(function(){
      $("#tab_pack #product_list td.editable").removeClass("edit-focus");
    });

    $("#tab_pack #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
       event.preventDefault();
        break;
      }
    });    

    // Generate Track
    $("#tab_pack #btn_pack_submit").click(function(){
      var packItemData = new Array();
      $('#tab_pack #product_list tbody tr').each(function(row, tr){
        var qty = $(tr).find('td:eq(5)').text().trim() * $(tr).find('td:eq(8)').text().trim();
        packItemData.push({
          "quantity" : $(tr).find('td:eq(5)').text().trim(),
          "note" :$(tr).find('td:eq(6)').text().trim(),
          "id" : $(tr).find('td:eq(7)').text().trim(),
          "unit_ratio" : $(tr).find('td:eq(8)').text().trim(),
          "unit_id" : $(tr).find('td:eq(9)').text().trim(),
          "unit_name" : $(tr).find('td:eq(3)').text().trim()
        });    
      }); 
      var reqUrl = $('#pack_req_url').val();
      var data = {pack_attributes: packItemData, id: $('#ship_order_id').val()};
      do_activity(reqUrl, data, 'pack');
    });    

    //Remove Track
    $("#tab_pack a.remove_track_link").click(function(){
      var r = confirm("Do you want to remove package?");
      if (r == true) {
        var reqUrl = $('#pack_remove_url').val();
        var data = {activity: $(this).data('activity'), type: 'pack'};
        do_activity(reqUrl, data, 'pack');
      }      
    });    

    $("#pack_activity_list tr.even").hide();    
    $("#pack_activity_list tr.odd").click(function(){
        $(this).next("tr").toggle();
    });


    // Generate Track From Popup
    $("#package_modal #btn_create_package").click(function(){
      var packItemData = new Array();
      $('#package_modal #product_list tbody tr').each(function(row, tr){
        packItemData.push({
          "quantity" : $(tr).find('td:eq(5)').text().trim(),
          "note" :$(tr).find('td:eq(6)').text().trim(),
          "id" : $(tr).find('td:eq(7)').text().trim(),
          "unit_ratio" : $(tr).find('td:eq(8)').text().trim(),
          "unit_id" : $(tr).find('td:eq(9)').text().trim(),
          "unit_name" : $(tr).find('td:eq(3)').text().trim()
        });    
      }); 
      var reqUrl = $('#pack_req_url').val();
      var data = {pack_attributes: packItemData, id: $('#ship_order_id').val()};
      do_activity(reqUrl, data, 'pack');
    });    

    $("#package_modal #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#package_modal #product_list td.editable").focusout(function(){
      $("#package_modal #product_list td.editable").removeClass("edit-focus");
    });

    $("#package_modal #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
       event.preventDefault();
        break;
      }
    });    
  }

  var do_activity = function(reqUrl, data, page, method = 'post'){
    $.ajax({
      url: reqUrl,
      type: method,
      datatype: 'json',
      data: data,
      success: function(data){
        if(data.Result == "OK"){
          $.cookie("order_detail_last", page);
          window.location.reload();
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

  var rollbackLastAction = function(){
    if($.cookie("order_detail_last") == '')
      return;

    $('.tab-pane').removeClass('active');
    $('ul.bar_tabs li').removeClass('active');

    switch($.cookie("order_detail_last")){
    case 'pack':
      $('#tab_pack').addClass('active');
      $('ul.bar_tabs li.tab-pack').addClass('active');      
      break;
    case 'ship':
      $('#tab_shipment').addClass('active');
      $('ul.bar_tabs li.tab-shipment').addClass('active');      
      break;
    case 'invoice':
      $('#tab_invoice').addClass('active');
      $('ul.bar_tabs li.tab-invoice').addClass('active');      
      break;
    }

    $.cookie("order_detail_last", '');
  }

  var handleSalesOrderAction = function(){
    /*************** Cancel Action *******************************/
    $('.sales-order-cancel').click(function(){
      $('#cancel_sales_order_token').text($(this).data('token'));
      $('#cancel_order_reason').val('');
      $('#cancel_sales_order_id').val($(this).data('id'));
    });

    $('#button_cancel_sales_order').click(function(){      
      var sales_order_id = $('#cancel_sales_order_id').val();
      var reqUrl = '/sales_orders/' + sales_order_id + '/cancel'
      var sales_order_token = $('#cancel_sales_order_token').val();
      var mode = $(this).data('type');
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        data: { reason: $('#cancel_order_reason').val() },
        success: function(data){
          if(data.Result == "OK"){
            window.location.reload();
            $('#button_close_cancel').trigger('click');
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

  }


  var handleShipTab = function(){
    $('.group-checkable').click(function(){
      var parent_table = $(this).parents('table');
      if($(this).is(':checked') == true){
        parent_table.find(".bulk_action input[name='table_records']").prop("checked",true);
      } else {
        parent_table.find(".bulk_action input[name='table_records']").prop("checked",false);
      }
      $.uniform.update();
    });    

    $("#tab_shipment #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#tab_shipment #product_list td.editable").focusout(function(){
      $("#product_list td.editable").removeClass("edit-focus");
    });

    $("#tab_shipment #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
       event.preventDefault();
        break;
      }
    });    

    $("#tab_shipment #btn_ship_submit").click(function(){
      var records = [];
      $("#tab_shipment .bulk_action input[name='table_records']:checked").each(function() {
        records.push("'" + $(this).val() + "'");
      });

      var pack_tokens = '';

      if (records.length) {
        pack_tokens = records.join(",");
      } else {
        return;
      }

      var reqUrl = $('#ship_req_url').val();
      var data = {pack_tokens: pack_tokens, id: $('#ship_order_id').val(), track_number: $('#tracking_number').val()};
      do_activity(reqUrl, data, 'ship');
    });

    //Remove Track
    $("#tab_shipment a.remove_track_link").click(function(){
      var r = confirm("Do you want to remove shipment?");
      if (r == true) {
        var reqUrl = $('#ship_remove_url').val();    
        var data = {activity: $(this).data('activity'), type: 'ship'};
        do_activity(reqUrl, data, 'ship');
      }      
    });    

    $("#tab_shipment a.confirm_ship_link").click(function(){
      var reqUrl = $('#ship_invoice_url').val();    
      var data = {ship_token: $(this).data('activity'), type: 'invoice', id: $('#ship_order_id').val()};
      do_activity(reqUrl, data, 'invoice');
    });    

    $("#ship_activity_list tr.even").hide();
    $("#ship_activity_list tr.odd").click(function(){
        $(this).next("tr").toggle();
    });

    // Handling Shipment Popup

    $("#shipment_modal #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#shipment_modal #product_list td.editable").focusout(function(){
      $("#product_list td.editable").removeClass("edit-focus");
    });

    $("#shipment_modal #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
       event.preventDefault();
        break;
      }
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

      var reqUrl = $('#ship_req_url').val();
      var data = {pack_tokens: pack_tokens, id: $('#ship_order_id').val(), track_number: $('#modal_tracking_number').val()};
      do_activity(reqUrl, data, 'ship');
    });

  }

  var handleInvoiceTab = function(){
    //Remove Invoice
    $("#tab_invoice a.remove_invoice_link").click(function(){
      var r = confirm("Do you want to remove invoice?");
      if (r == true) {
        var reqUrl = $(this).data('activity');    
        var data = {};
        do_activity(reqUrl, data, 'invoice', 'delete');        
      }
    });    


  }

  var handleInvoiceModal = function(){
    // Generate Invoice From Popup
    $("#invoice_modal #btn_create_invoice").click(function(){
      var invoiceItemData = new Array();
      $('#invoice_modal #product_list tbody tr').each(function(row, tr){
        invoiceItemData.push({
          "quantity" : $(tr).find('td:eq(2)').text().trim(),
          "unit_price" : $(tr).find('td:eq(4)').text().trim(),
          "discount" : $(tr).find('td:eq(5)').text().trim(),
          "tax" : $(tr).find('td:eq(6)').text().trim(),
          "sub_total" : $(tr).find('td:eq(7)').text().trim(),
          "id" : $(tr).find('td:eq(8)').text().trim(),
          "type" : $(tr).find('td:eq(9)').text().trim()
        });    
      }); 
      var reqUrl = $('#invoice_req_url').val();
      var data = {
          invoice_attributes: invoiceItemData, 
          // paid: $('#invoice_modal #paid_amount').val(),
          sub_total: $('#invoice_modal #sub_total_cell').text(),
          discount_total: $('#invoice_modal #discount_total_cell').text(),
          tax_total: $('#invoice_modal #tax_total_cell').text(),
          shipping_total: '0',
          total: $('#invoice_modal #total_cell').text()
      };
      do_activity(reqUrl, data, 'invoice');
    });    

    $("#invoice_modal #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#invoice_modal #product_list td.editable").focusout(function(){
      $("#invoice_modal #product_list td.editable").removeClass("edit-focus");
      calculateInvoice();
    });

    $("#invoice_modal #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateInvoice();
        event.preventDefault();
        break;
      }
    });

    $("#invoice_modal #paid_amount").keydown(function(event){
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
        var price = $(tr).find('td:eq(4)').text().trim();
        var discount = $(tr).find('td:eq(5)').text().trim();
        var tax = $(tr).find('td:eq(6)').text().trim();
        row_amount = quantity * price * (100 - discount) * 0.01;
        $(tr).find('td:eq(7)').text(row_amount.toFixed(2));

        row_amount = $(tr).find('td:eq(7)').text().trim();

        subTotal += (row_amount * 1);
        discountTotal += quantity * price * discount * 0.01;
        taxTotal += quantity * price * tax * 0.01;
        total += (row_amount * 1) + quantity * price * tax * 0.01;
      });

      var paid = 0;//$( modalId + ' #paid_amount').val();
      change = paid - total;
      $( modalId + ' #sub_total_cell').text(subTotal.toFixed(2));
      $( modalId + ' #discount_total_cell').text(discountTotal.toFixed(2));
      $( modalId + ' #tax_total_cell').text(taxTotal.toFixed(2));
      $( modalId + ' #total_cell').text(total.toFixed(2));
      $( modalId + ' #change_cell').text(change.toFixed(2));
    }

    $(".invoice_detail_modal #btn_update_invoice").click(function(){
      var invoiceItemData = new Array();
      var modalId = '#inovice_detail_modal_' + $(this).data('itemid');
      var action_name = ($(this).hasClass('btn-primary')) ? 'update' : 'confirm';

      $( modalId + ' #product_list tbody tr').each(function(row, tr){
        invoiceItemData.push({
          "quantity" : $(tr).find('td:eq(2)').text().trim(),
          "unit_price" : $(tr).find('td:eq(4)').text().trim(),
          "discount" : $(tr).find('td:eq(5)').text().trim(),
          "tax" : $(tr).find('td:eq(6)').text().trim(),
          "sub_total" : $(tr).find('td:eq(7)').text().trim(),
          "id" : $(tr).find('td:eq(8)').text().trim(),
          "type" : $(tr).find('td:eq(9)').text().trim()
        });    
      }); 
      var reqUrl = $(this).data('url');
      var data = {
          invoice_attributes: invoiceItemData,
          action_name: action_name, 
          // paid: $( modalId + ' #paid_amount').val(),
          sub_total: $( modalId + ' #sub_total_cell').text(),
          discount_total: $( modalId + ' #discount_total_cell').text(),
          tax_total: $( modalId + ' #tax_total_cell').text(),
          shipping_total: '0',
          total: $( modalId + ' #total_cell').text()
      };
      do_activity(reqUrl, data, 'invoice', 'put');
    });    

    $(".invoice_detail_modal #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $(".invoice_detail_modal #product_list td.editable").focusout(function(){
      $(this).removeClass("edit-focus");
      var modalId = '#inovice_detail_modal_' + $(this).parent().parent().parent().data('invoice');
      calculateInvoice(modalId);
    });

    $(".invoice_detail_modal #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        var modalId = '#inovice_detail_modal_' + $(this).parent().parent().parent().data('invoice');
        calculateInvoice(modalId);
        event.preventDefault();
        break;
      }
    });
  }

  var handleInvoiceAction = function() {
    $('.invoice-approve').click(function(){
      var reqUrl = '/invoices/' + $(this).data('id') + '/approve'
      var invoice_id = $(this).data('id');
      var invoice_token = $(this).data('token');
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.Result == "OK"){
            $('#invoice_status_' + invoice_id).html('<span class="label label-info">APPROVED</span>');
            $('#invoice_approve_' + invoice_id).hide();
            $('#invoice_payment_' + invoice_id).show();
            $('.invoice_approve_section_' + invoice_id).hide();
            $('.invoice_cancel_section_' + invoice_id).show();            
            new PNotify({
              title: 'Success!',
              text: 'Invoice ' + invoice_token + ' is approved.',
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

    $('#payment_date').daterangepicker({
      singleDatePicker: true,
      calender_style: "picker_4",
      format: 'DD-MM-YYYY'
      }, function(start, end, label) {
    });

    $('.record-payment').click(function(){
      $('#payment_invoice_token').text($(this).data('token'));
      $('#payment_date').val('');
      $('#payment_amount').val($(this).data('balance'));
      $('#reference_no').val('');
      $('#note').val('');
      $('#payment_invoice_id').val($(this).data('id'));
      $('#payment_mode').val('');
    });

    $('#button_record_payment').click(function(){
      var reqUrl = '/invoices/' + $('#payment_invoice_id').val() + '/add_payment'
      var invoice_id = $('#payment_invoice_id').val();
      var balance = $('#invoice_balance_' + invoice_id).text().trim();
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        data: {
          payment_date: $('#payment_date').val(),
          payment_amount: $('#payment_amount').val(),
          payment_mode: $('#payment_mode').val(),
          reference_no: $('#reference_no').val(),
          note: $('#note').val()          
        },
        success: function(data){
          if(data.Result == "OK"){
            var new_balance = data.Balance;
            $('#invoice_paid_' + invoice_id).text(data.Paid);
            $('#invoice_payment_' + invoice_id).data('balance', new_balance);
            if(new_balance <= 0){
              $('#invoice_status_' + invoice_id).html('<span class="label label-success">PAID</span>');
            } else {
              $('#invoice_status_' + invoice_id).html('<span class="label label-warning">PARTIAL PAID</span>');
            }
            $('#cancel_record_payment').trigger('click');
            new PNotify({
              title: 'Success!',
              text: $('#payment_amount').val() + ' Payment is made successfully.',
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
            text: 'Request is not processed.',
            type: 'error'
          });              
        }   
      });      
    });

    $('.invoice-cancel').click(function(){
      $('#cancel_invoice_token').text($(this).data('token'));
      $('#cancel_reason').val('');
      $('#cancel_invoice_id').val($(this).data('id'));
    });

    $('#button_cancel_invoice').click(function(){      
      var invoice_id = $('#cancel_invoice_id').val();
      var reqUrl = '/invoices/' + invoice_id + '/cancel'
      var invoice_token = $('#cancel_invoice_token').val();
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        data: { reason: $('#cancel_reason').val() },
        success: function(data){
          if(data.Result == "OK"){
            $('#invoice_status_' + invoice_id).html('<span class="label label-danger">CANCELLED</span>');
            $('.invoice_approve_section_' + invoice_id).show();
            $('.invoice_cancel_section_' + invoice_id).hide();
            new PNotify({
              title: 'Success!',
              text: 'Invoice ' + invoice_token + ' is cancelled.',
              type: 'success',
              delay: 3000
            });
            $('#button_close_cancel').trigger('click');
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
    
  }

  return {
    //main function to initiate the module
    initSalesOrderNavList: function () {
      initialNavigatorList();
      rollbackLastAction();
      handleSalesOrderAction();
    },

    handleOrderPackageTab: function() {
      handlePackageTab();
    },

    handleOrderShipTab: function() {
      handleShipTab();
    },

    handleOrderInvoiceTab: function(){
      handleInvoiceTab();
      handleInvoiceModal();
      handleInvoiceAction();
    }
  };
}();  

