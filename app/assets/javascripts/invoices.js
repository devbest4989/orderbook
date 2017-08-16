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
      if($(this).is(':checked') == true){
        $(".bulk_action input[name='table_records']").prop("checked",true);
      } else {
        $(".bulk_action input[name='table_records']").prop("checked",false);
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

  return {
    initInvoiceList: function () {
      initialHeader();
      handleOrderBy();
      handleGroupSelect();
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
          payment_amount: $('#payment_amount').val()
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

      $('#payment_date').val('');
      $('#payment_amount').val('');
    });

    $('#cancel_record_payment').click(function(){
      $('#payment_date').val('');
      $('#payment_amount').val('');
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
        var price = $(tr).find('td:eq(3)').text().trim();
        var discount = $(tr).find('td:eq(4)').text().trim();
        var tax = $(tr).find('td:eq(5)').text().trim();
        row_amount = quantity * price * (100 -discount) * 0.01;
        $(tr).find('td:eq(6)').text(row_amount.toFixed(2));

        subTotal += row_amount;
        discountTotal += quantity * price * discount * 0.01;
        taxTotal += quantity * price * tax * 0.01;
        total += row_amount + quantity * price * tax * 0.01;
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
          "discount" : $(tr).find('td:eq(4)').text().trim(),
          "tax" : $(tr).find('td:eq(5)').text().trim(),
          "sub_total" : $(tr).find('td:eq(6)').text().trim(),
          "id" : $(tr).find('td:eq(7)').text().trim()
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
      var modalId = '#' + $(this).parents().find('.invoice_detail_modal').attr('id');
      calculateInvoice(modalId);
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
    }
  };
}();  