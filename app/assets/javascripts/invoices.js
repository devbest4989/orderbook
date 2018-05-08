var InvoicesCommon = function () {

  return {
    initSiderMenuList: function () {
      $('#sidebar-menu li').removeClass('current-page');
      $('#sidebar-menu li').removeClass('active');
      $('#sidebar-menu li.nav-invoices').addClass('active');
    }
  };
}();  

var InvoiceList = function(){
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
      $('#payment_original_balance').val($(this).data('balance'));
      $('#reference_no').val('');
      $('#note').val('');
      $('#payment_invoice_id').val($(this).data('id'));
      $('#payment_mode').val('');      

      $('#pay_credit_note').prop("checked",false);
      $('.credit-note-section').show();      
      $.uniform.update();

      var reqUrl = '/invoices/' + $(this).data('id') + '/invoice_detail_info';
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#total_credit_note').val(data.pending_credit_notes);
            if(data.pending_credit_notes == 0){
              $('.credit-note-section').hide();
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

    $("#pay_credit_note").on('change', function (e) {
      var total = $(this).prop("checked") ? $('#total_credit_note').val() : 0;
      var balance = $('#payment_original_balance').val() - total;
      $('#payment_amount').val(balance.toFixed(2));
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
          note: $('#note').val(),
          is_include_credit_note: $("#pay_credit_note").prop("checked")
        },
        success: function(data){
          if(data.Result == "OK"){
            var new_balance = data.Balance;
            $('#invoice_balance_' + invoice_id).text(new_balance);
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

    /*********************Credit Note*****************************/
    $('.invoice-action').click(function(){      
      $('#credit_note_invoice_token').text($(this).data('token'));
      $('#credit_note_invoice_id').val($(this).data('id'));
      var reqUrl = '/invoices/' + $(this).data('id') + '/invoice_detail_info';
      var type = $(this).data('type');

      if(type == 'write_off'){
        $('#credit_note_modal_title').text('Sales Order Invoice - Write Off');
        $('#btn_credit_note_invoice').text('Write Off');
        $('#credit_note_modal_type').val(type);
      } else {
        $('#credit_note_modal_title').text('Sales Order Invoice - Credit Note');
        $('#btn_credit_note_invoice').text('Credit Note');
        $('#credit_note_modal_type').val(type);
      }
      
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#credit_note_customer_name').text(data.customer);
            $('#credit_note_invoice_token').text(data.token);
            $('#credit_note_todo_url').val(data.credit_note_url);
            $('#credit_note_customer_bill_address').text(data.bill_address);
            $('#credit_note_invoice_date').text(data.invoice_date);
                        
            var template = '';
            var total_available = 0;
            $.each( data.invoice_items, function( key, value ) {
              template += '<tr><td>'+value.sku+'</td>';
              template += '<td>'+value.name+'</td>';
              template += '<td>'+value.quantity+'</td>';
              template += '<td>'+value.unit_name+'</td>';
              template += '<td class="editable" contentEditable="true">0</td>';
              template += '<td>'+value.unit_price+'</td>';
              template += '<td>'+value.discount_rate+'</td>';
              template += '<td>'+value.tax_rate+'</td>';
              template += '<td></td>';
              template += '<td class="editable" contentEditable="true"></td>';
              template += '<td style="display:none; ">'+value.id+'</td>';
              template += '<td style="display:none; "></td></tr>';
              total_available += value.quantity;
            });
            $('#credit_note_body').html(template);

            if(total_available > 0){
              $('#btn_credit_note_invoice').show();
            } else {
              $('#btn_credit_note_invoice').hide();
            }

            $('#sub_total_cell').html('');
            $('#discount_total_cell').html('');
            $('#tax_total_cell').html('');
            $('#total_cell').html('');

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

    $('#btn_credit_note_invoice').click(function(){
      var reqUrl = $('#credit_note_todo_url').val();
      var invoice_id = $('#credit_note_invoice_id').val();
      var balance = $('#total_cell').text().trim();

      var invoiceItemData = new Array();
      $( '#product_list tbody tr').each(function(row, tr){
        invoiceItemData.push({
          "quantity" : $(tr).find('td:eq(4)').text().trim(),
          "discount" : $(tr).find('td:eq(6)').text().trim(),
          "tax" : $(tr).find('td:eq(7)').text().trim(),
          "sub_total" : $(tr).find('td:eq(8)').text().trim(),
          "note" : $(tr).find('td:eq(9)').text().trim(),
          "id" : $(tr).find('td:eq(10)').text().trim(),
          "total" : $(tr).find('td:eq(11)').text().trim()
        });    
      }); 

      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        data: {
          items: invoiceItemData,
          type: $('#credit_note_modal_type').val()
        },
        success: function(data){
          if(data.Result == "OK"){
            var new_balance = data.Balance;
            var total_credit_note = data.CreditBalance;
            if(total_credit_note)
              $('#invoice_balance_' + invoice_id).html(new_balance + '<br/>' + total_credit_note + 'CR');
            else
              $('#invoice_balance_' + invoice_id).text(new_balance);

            $('#invoice_payment_' + invoice_id).data('balance', new_balance);
            $('#invoice_status_' + invoice_id).html('<span class="label '+data.StatusClass+'">'+data.Status+'</span>');
            $('#btn_credit_note_cancel').trigger('click');
            if($('#credit_note_modal_type').val() == 'write_off'){
              $('#invoice_credit_note_'+invoice_id).hide();
            } else {
              $('#invoice_cancel_'+invoice_id).hide();
            }

            new PNotify({
              title: 'Success!',
              text: 'Action has done successfully.',
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

    $(document).on('focusout', '#product_list td.editable', function(){
      $(this).removeClass("edit-focus");
      calculateInvoice();
    });

    $(document).on('keydown', '#product_list td.editable', function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateInvoice();
        event.preventDefault();
        break;
      }
    });

    function calculateInvoice(){
      var subTotal = 0, 
          discountTotal = 0, 
          taxTotal = 0, 
          total = 0, 
          change = 0;        
      $( '#product_list tbody tr').each(function(row, tr){
        var row_amount = 0;
        var quantity = $(tr).find('td:eq(4)').text().trim();
        var price = $(tr).find('td:eq(5)').text().trim();
        var discount = $(tr).find('td:eq(6)').text().trim();
        var tax = $(tr).find('td:eq(7)').text().trim();
        row_amount = quantity * price * (100 -discount) * 0.01;
        $(tr).find('td:eq(8)').text(row_amount.toFixed(2));

        row_amount = $(tr).find('td:eq(8)').text().trim();

        subTotal += (row_amount * 1);
        discountTotal += quantity * price * discount * 0.01;
        taxTotal += quantity * price * tax * 0.01;
        total += (row_amount * 1) + quantity * price * tax * 0.01;
        $(tr).find('td:eq(11)').text(total.toFixed(2));
      });

      var paid = 0;//$( '#paid_amount').val();
      $('.payment-record').each(function(index, item){
        paid += parseFloat($(item).text());
      });

      $( '#sub_total_cell').text(subTotal.toFixed(2));
      $( '#discount_total_cell').text(discountTotal.toFixed(2));
      $( '#tax_total_cell').text(taxTotal.toFixed(2));
      $( '#total_cell').text(total.toFixed(2));
    }
  }

  return {
    initInvoiceList: function () {
      initialHeader();
      handleOrderBy();
      handleGroupSelect();
      handleInvoiceAction();
    }
  };
}();


var InvoiceDetail = function () {
  var initialNavigatorList = function(){
    $('#sidebar-menu li').removeClass('current-page');
    $('#sidebar-menu li').removeClass('active');
    $('#sidebar-menu li.nav-invoices').addClass('active');
    $('#sidebar-menu li.nav-invoices ul.child_menu li').removeClass('current-page');
    $('#sidebar-menu li.nav-invoices ul.child_menu li:nth-child(1)').addClass('current-page');
    $('#sidebar-menu li.nav-invoices ul.child_menu').show();

    $('#invoice_side_menu').mCustomScrollbar({theme:"minimal-dark", scrollbarPosition: "outside"});    

    var active_elem = 'li.' + $('#active_elem').data('elem') + ' a';
    $(active_elem).addClass('nav-active');    
    $('#invoice_side_menu').mCustomScrollbar("scrollTo", active_elem);
  }

  var calculateOverviewPercents = function(){
    var purchase_price = $('.info-list .purchase_value').val();
    $('.sell-price-row').each(function(){
      if(purchase_price == '' || ($(this).find('.sell-price').val() == '' && $(this).find('.mp-percent').val() == '')){
        return;
      }

      var selling_price = parseFloat($(this).find('.sell-price').val());
      var mp_percent = (selling_price - purchase_price) * 100 / purchase_price;
      var gp_percent = (selling_price - purchase_price) * 100 / selling_price;

      $(this).find('.mp-percent').html(mp_percent.toFixed(2) + " %");
      $(this).find('.gp-percent').html(gp_percent.toFixed(2) + " %");              
    });    
  }

  var actionHandler = function(){

    $("#pay_credit_note").on('change', function (e) {
      var total = $(this).prop("checked") ? $('#total_credit_note').val() : 0;
      var balance = $('#change_cell').text().trim() - total;
      $('#payment_amount').val(balance.toFixed(2));
    });

    $('#payment_date').daterangepicker({
      singleDatePicker: true,
      calender_style: "picker_4",
      format: 'DD-MM-YYYY'
      }, function(start, end, label) {
    });

    $('#button_record_payment').click(function(){      
      var reqUrl = '/invoices/' + $('#invoice_id').val() + '/add_payment'
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        data: {
          payment_date: $('#payment_date').val(),
          payment_amount: $('#payment_amount').val(),
          payment_mode: $('#payment_mode').val(),
          reference_no: $('#reference_no').val(),
          note: $('#note').val(),
          is_include_credit_note: $("#pay_credit_note").prop("checked")
        },
        success: function(data){
          if(data.Result == "OK"){
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
            text: 'Request is not processed.',
            type: 'error'
          });              
        }   
      });
    });

    $('#cancel_record_payment').click(function(){
      $('#payment_date').val('');
      $('#payment_amount').val('');
      $('#payment_mode').val('');
      $('#reference_no').val('');
      $('#note').val('');
    });

    $('a.record-payment').click(function(){
      $('#payment_amount').val($('#change_cell').text().trim());      
    });

    function calculateInvoice(){
      var subTotal = 0, 
          discountTotal = 0, 
          taxTotal = 0, 
          total = 0, 
          change = 0;        
      $( '#product_list tbody tr').each(function(row, tr){
        var row_amount = 0;
        var quantity = $(tr).find('td:eq(2)').text().trim();
        var price = $(tr).find('td:eq(4)').text().trim();
        var discount = $(tr).find('td:eq(5)').text().trim();
        var tax = $(tr).find('td:eq(6)').text().trim();
        row_amount = quantity * price * (100 -discount) * 0.01;
        $(tr).find('td:eq(7)').text(row_amount.toFixed(2));

        row_amount = $(tr).find('td:eq(7)').text().trim();

        subTotal += (row_amount * 1);
        discountTotal += quantity * price * discount * 0.01;
        taxTotal += quantity * price * tax * 0.01;
        total += (row_amount * 1) + quantity * price * tax * 0.01;
      });

      var paid = 0;//$( '#paid_amount').val();
      $('.payment-record').each(function(index, item){
        paid += parseFloat($(item).text());
      });

      change = total - paid;
      $( '#sub_total_cell').text(subTotal.toFixed(2));
      $( '#discount_total_cell').text(discountTotal.toFixed(2));
      $( '#tax_total_cell').text(taxTotal.toFixed(2));
      $( '#total_cell').text(total.toFixed(2));
      $( '#change_cell').text(change.toFixed(2));
    }

    $('#edit_invoice').click(function(){
      $('#btn_update_invoice').show();
      $('.editable').each(function(index, item){
        $(item).attr('contentEditable', true);
      });
    });

    $("#btn_update_invoice").click(function(){
      var invoiceItemData = new Array();
      var action_name = 'update';

      $( '#product_list tbody tr').each(function(row, tr){
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
          // paid: $( '#paid_amount').val(),
          sub_total: $( '#sub_total_cell').text(),
          discount_total: $( '#discount_total_cell').text(),
          tax_total: $( '#tax_total_cell').text(),
          shipping_total: '0',
          total: $( '#total_cell').text()
      };
      do_activity(reqUrl, data, 'invoice', 'put');
    });    

    $("#product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#product_list td.editable").focusout(function(){
      $(this).removeClass("edit-focus");
      calculateInvoice();
    });

    $("#product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateInvoice();
        event.preventDefault();
        break;
      }
    });
  }

  var modalHandler = function(){
    $('.invoice-action').click(function(){      
      $('#credit_note_invoice_token').text($(this).data('token'));
      $('#credit_note_invoice_id').val($(this).data('id'));
      var reqUrl = '/invoices/' + $(this).data('id') + '/invoice_detail_info';
      var type = $(this).data('type');

      if(type == 'write_off'){
        $('#credit_note_modal_title').text('Sales Order Invoice - Write Off');
        $('#btn_credit_note_invoice').text('Write Off');
        $('#credit_note_modal_type').val(type);
      } else {
        $('#credit_note_modal_title').text('Sales Order Invoice - Credit Note');
        $('#btn_credit_note_invoice').text('Credit Note');
        $('#credit_note_modal_type').val(type);
      }
      
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.result == "OK"){
            $('#credit_note_customer_name').text(data.customer);
            $('#credit_note_invoice_token').text(data.token);
            $('#credit_note_todo_url').val(data.credit_note_url);
            $('#credit_note_customer_bill_address').text(data.bill_address);
            $('#credit_note_invoice_date').text(data.invoice_date);
                        
            var template = '';
            var total_available = 0;
            $.each( data.invoice_items, function( key, value ) {
              template += '<tr><td>'+value.sku+'</td>';
              template += '<td>'+value.name+'</td>';
              template += '<td>'+value.quantity+'</td>';
              template += '<td>'+value.unit_name+'</td>';
              template += '<td class="editable" contentEditable="true">0</td>';
              template += '<td>'+value.unit_price+'</td>';
              template += '<td>'+value.discount_rate+'</td>';
              template += '<td>'+value.tax_rate+'</td>';
              template += '<td></td>';
              template += '<td class="editable" contentEditable="true"></td>';
              template += '<td style="display:none; ">'+value.id+'</td>';
              template += '<td style="display:none; "></td></tr>';
              total_available += value.quantity;
            });
            $('#credit_note_body').html(template);

            if(total_available > 0){
              $('#btn_credit_note_invoice').show();
            } else {
              $('#btn_credit_note_invoice').hide();
            }

            $('#sub_total_cell').html('');
            $('#discount_total_cell').html('');
            $('#tax_total_cell').html('');
            $('#total_cell').html('');

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

    $('#btn_credit_note_invoice').click(function(){
      var reqUrl = $('#credit_note_todo_url').val();
      var invoice_id = $('#credit_note_invoice_id').val();
      var balance = $('#total_cell').text().trim();

      var invoiceItemData = new Array();
      $( '#product_list_modal tbody tr').each(function(row, tr){
        invoiceItemData.push({
          "quantity" : $(tr).find('td:eq(4)').text().trim(),
          "discount" : $(tr).find('td:eq(6)').text().trim(),
          "tax" : $(tr).find('td:eq(7)').text().trim(),
          "sub_total" : $(tr).find('td:eq(8)').text().trim(),
          "note" : $(tr).find('td:eq(9)').text().trim(),
          "id" : $(tr).find('td:eq(10)').text().trim(),
          "total" : $(tr).find('td:eq(11)').text().trim()
        });    
      }); 

      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        data: {
          items: invoiceItemData,
          type: $('#credit_note_modal_type').val()
        },
        success: function(data){
          if(data.Result == "OK"){
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
            text: 'Request is not processed.',
            type: 'error'
          });              
        }   
      });      
    });

    $(document).on('focusout', '#product_list_modal td.editable', function(){
      $(this).removeClass("edit-focus");
      var modalId = '#' + $(this).parents().find('.invoice_detail_modal').attr('id');
      calculateModalInvoice(modalId);
    });

    $(document).on('keydown', '#product_list_modal td.editable', function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateModalInvoice();
        event.preventDefault();
        break;
      }
    });

    function calculateModalInvoice(){
      var subTotal = 0, 
          discountTotal = 0, 
          taxTotal = 0, 
          total = 0, 
          change = 0;        
      $( '#product_list_modal tbody tr').each(function(row, tr){
        var row_amount = 0;
        var quantity = $(tr).find('td:eq(4)').text().trim();
        var price = $(tr).find('td:eq(5)').text().trim();
        var discount = $(tr).find('td:eq(6)').text().trim();
        var tax = $(tr).find('td:eq(7)').text().trim();
        row_amount = quantity * price * (100 -discount) * 0.01;
        $(tr).find('td:eq(8)').text(row_amount.toFixed(2));

        row_amount = $(tr).find('td:eq(8)').text().trim();

        subTotal += (row_amount * 1);
        discountTotal += quantity * price * discount * 0.01;
        taxTotal += quantity * price * tax * 0.01;
        total += (row_amount * 1) + quantity * price * tax * 0.01;
        $(tr).find('td:eq(11)').text(total.toFixed(2));
      });

      var paid = 0;//$( '#paid_amount').val();
      $('.payment-record').each(function(index, item){
        paid += parseFloat($(item).text());
      });

      $( '#modal_sub_total_cell').text(subTotal.toFixed(2));
      $( '#modal_discount_total_cell').text(discountTotal.toFixed(2));
      $( '#modal_tax_total_cell').text(taxTotal.toFixed(2));
      $( '#modal_total_cell').text(total.toFixed(2));
    }    
  }

  var do_activity = function(reqUrl, data, page, method = 'post'){
    $.ajax({
      url: reqUrl,
      type: method,
      datatype: 'json',
      data: data,
      success: function(data){
        if(data.Result == "OK"){
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


  return {
    //main function to initiate the module
    initInvoiceNavList: function () {
      initialNavigatorList();
    },

    initInvoiceOverview: function(){
      calculateOverviewPercents();
    },

    initActionHandler: function(){
      actionHandler();
      modalHandler();
    }
  };
}();  