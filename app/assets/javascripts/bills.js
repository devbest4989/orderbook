var BillsCommon = function () {

  return {
    initSiderMenuList: function () {
      $('#sidebar-menu li').removeClass('current-page');
      $('#sidebar-menu li').removeClass('active');
      $('#sidebar-menu li.nav-bills').addClass('active');
    }
  };
}();  

var BillList = function(){
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

  var handleBillAction = function() {
    $('.bill-approve').click(function(){
      var reqUrl = '/bills/' + $(this).data('id') + '/approve'
      var bill_id = $(this).data('id');
      var bill_token = $(this).data('token');
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        success: function(data){
          if(data.Result == "OK"){
            $('#bill_status_' + bill_id).html('<span class="label label-info">APPROVED</span>');
            $('#bill_approve_' + bill_id).hide();
            $('#bill_payment_' + bill_id).show();
            new PNotify({
              title: 'Success!',
              text: 'Bill ' + bill_token + ' is approved.',
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

    $('.make-payment').click(function(){
      $('#payment_bill_token').text($(this).data('token'));
      $('#payment_date').val('');
      $('#payment_amount').val($(this).data('balance'));
      $('#reference_no').val('');
      $('#note').val('');
      $('#payment_bill_id').val($(this).data('id'));
      $('#payment_mode').val('');
    });

    $('#button_record_payment').click(function(){
      var reqUrl = '/bills/' + $('#payment_bill_id').val() + '/add_payment'
      var bill_id = $('#payment_bill_id').val();
      var balance = $('#bill_balance_' + bill_id).text().trim();
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
            $('#bill_balance_' + bill_id).text(new_balance);
            $('#bill_payment_' + bill_id).data('balance', new_balance);
            if(new_balance <= 0){
              $('#bill_status_' + bill_id).html('<span class="label label-success">PAID</span>');
            } else {
              $('#bill_status_' + bill_id).html('<span class="label label-warning">PARTIAL PAID</span>');
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
  }

  return {
    initBillList: function () {
      initialHeader();
      handleOrderBy();
      handleGroupSelect();
      handleBillAction();
    }
  };
}();


var BillDetail = function () {
  var initialNavigatorList = function(){
    $('#sidebar-menu li').removeClass('current-page');
    $('#sidebar-menu li').removeClass('active');
    $('#sidebar-menu li.nav-bills').addClass('active');
    $('#sidebar-menu li.nav-bills ul.child_menu li').removeClass('current-page');
    $('#sidebar-menu li.nav-bills ul.child_menu li:nth-child(1)').addClass('current-page');
    $('#sidebar-menu li.nav-bills ul.child_menu').show();

    $('#bill_side_menu').mCustomScrollbar({theme:"minimal-dark", scrollbarPosition: "outside"});    

    var active_elem = 'li.' + $('#active_elem').data('elem') + ' a';
    $(active_elem).addClass('nav-active');    
    $('#bill_side_menu').mCustomScrollbar("scrollTo", active_elem);
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
      var reqUrl = '/bills/' + $('#bill_id').val() + '/add_payment'
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

    function calculateBill(){
      var subTotal = 0, 
          discountTotal = 0, 
          taxTotal = 0, 
          total = 0, 
          change = 0;        
      $( '#product_list tbody tr').each(function(row, tr){
        var row_amount = 0;
        var quantity = $(tr).find('td:eq(2)').text().trim();
        var price = $(tr).find('td:eq(3)').text().trim();
        var tax = $(tr).find('td:eq(4)').text().trim();
        row_amount = quantity * price;
        $(tr).find('td:eq(5)').text(row_amount.toFixed(2));

        row_amount = $(tr).find('td:eq(5)').text().trim();

        subTotal += (row_amount * 1);
        taxTotal += quantity * price * tax * 0.01;
        total += (row_amount * 1) + quantity * price * tax * 0.01;
      });

      var paid = 0;//$( '#paid_amount').val();
      $('.payment-record').each(function(index, item){
        paid += parseFloat($(item).text());
      });

      change = total - paid;
      $( '#sub_total_cell').text(subTotal.toFixed(2));
      $( '#tax_total_cell').text(taxTotal.toFixed(2));
      $( '#total_cell').text(total.toFixed(2));
      $( '#change_cell').text(change.toFixed(2));
    }

    $('#edit_bill').click(function(){
      $('#btn_update_bill').show();
      $('.editable').each(function(index, item){
        $(item).attr('contentEditable', true);
      });
    });

    $("#btn_update_bill").click(function(){
      var billItemData = new Array();
      var action_name = 'update';

      $( '#product_list tbody tr').each(function(row, tr){
        billItemData.push({
          "quantity" : $(tr).find('td:eq(2)').text().trim(),
          "tax" : $(tr).find('td:eq(4)').text().trim(),
          "sub_total" : $(tr).find('td:eq(5)').text().trim(),
          "id" : $(tr).find('td:eq(6)').text().trim(),
          "type" : $(tr).find('td:eq(7)').text().trim()
        });    
      }); 
      var reqUrl = $(this).data('url');
      var data = {
          bill_attributes: billItemData,
          action_name: action_name, 
          // paid: $( '#paid_amount').val(),
          sub_total: $( '#sub_total_cell').text(),
          discount_total: $( '#discount_total_cell').text(),
          tax_total: $( '#tax_total_cell').text(),
          shipping_total: '0',
          total: $( '#total_cell').text()
      };
      do_activity(reqUrl, data, 'bill', 'put');
    });    

    $("#product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#product_list td.editable").focusout(function(){
      $(this).removeClass("edit-focus");
      var modalId = '#' + $(this).parents().find('.bill_detail_modal').attr('id');
      calculateBill(modalId);
    });

    $("#product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateBill();
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
    initBillNavList: function () {
      initialNavigatorList();
    },

    initBillOverview: function(){
      calculateOverviewPercents();
    },

    initActionHandler: function(){
      actionHandler();
    }
  };
}();