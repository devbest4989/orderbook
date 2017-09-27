
var PurchaseOrderDetail = function () {
  var initialNavigatorList = function(){    
    $('#order_side_menu').mCustomScrollbar({theme:"minimal-dark", scrollbarPosition: "outside"});    

    var active_elem = 'li.' + $('#active_elem').data('elem') + ' a';
    $(active_elem).addClass('nav-active');    
    $('#order_side_menu').mCustomScrollbar("scrollTo", active_elem);
  }

  var handleReceiveTab = function() {
    $("#tab_receive #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#tab_receive #product_list td.editable").focusout(function(){
      $("#tab_receive #product_list td.editable").removeClass("edit-focus");
    });

    $("#tab_receive #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
       event.preventDefault();
        break;
      }
    });    

    // Generate Track
    $("#tab_receive #btn_receive_submit").click(function(){
      var receiveItemData = new Array();
      $('#tab_receive #product_list tbody tr').each(function(row, tr){
        receiveItemData.push({
          "quantity" : $(tr).find('td:eq(4)').text().trim(),
          "note" :$(tr).find('td:eq(5)').text().trim(),
          "id" : $(tr).find('td:eq(6)').text().trim()
        });    
      }); 
      var reqUrl = $('#receive_req_url').val();
      var data = {receive_attributes: receiveItemData, id: $('#receive_order_id').val()};
      do_activity(reqUrl, data, 'receive');
    });    

    // Generate Track
    $("#tab_receive #btn_return_submit").click(function(){
      var returnItemData = new Array();
      $('#tab_receive #product_list tbody tr').each(function(row, tr){
        returnItemData.push({
          "quantity" : $(tr).find('td:eq(4)').text().trim(),
          "note" :$(tr).find('td:eq(5)').text().trim(),
          "id" : $(tr).find('td:eq(6)').text().trim()
        });    
      }); 
      var reqUrl = $('#return_req_url').val();
      var data = {return_attributes: returnItemData, id: $('#receive_order_id').val()};
      do_activity(reqUrl, data, 'receive');
    });    

    //Remove Track
    $("#tab_receive a.remove_track_link").click(function(){
      var r = confirm("Do you want to remove receive?");
      if (r == true) {
        var reqUrl = $('#receive_remove_url').val();
        var data = {activity: $(this).data('activity'), type: 'receive'};
        do_activity(reqUrl, data, 'receive');
      }      
    });

    //Remove Track
    $("#tab_receive a.remove_return_link").click(function(){
      var r = confirm("Do you want to remove return?");
      if (r == true) {
        var reqUrl = $('#receive_remove_url').val();
        var data = {activity: $(this).data('activity'), type: 'return'};
        do_activity(reqUrl, data, 'receive');
      }      
    });    

    $("#receive_activity_list tr.even").hide();    
    $("#receive_activity_list tr.odd").click(function(){
        $(this).next("tr").toggle();
    });


    // Generate Track From Popup
    $("#receive_modal #btn_create_receive").click(function(){
      var receiveItemData = new Array();
      $('#receive_modal #product_list tbody tr').each(function(row, tr){
        receiveItemData.push({
          "quantity" : $(tr).find('td:eq(4)').text().trim(),
          "note" :$(tr).find('td:eq(5)').text().trim(),
          "id" : $(tr).find('td:eq(6)').text().trim()
        });    
      }); 
      var reqUrl = $('#receive_req_url').val();
      var data = {receive_attributes: receiveItemData, id: $('#receive_order_id').val()};
      do_activity(reqUrl, data, 'receive');
    });    

    $("#receive_modal #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#receive_modal #product_list td.editable").focusout(function(){
      $("#receive_modal #product_list td.editable").removeClass("edit-focus");
    });

    $("#receive_modal #product_list td.editable").keydown(function(event){
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
    case 'receive':
      $('#tab_receive').addClass('active');
      $('ul.bar_tabs li.tab-receive').addClass('active');      
      break;
    case 'ship':
      $('#tab_shipment').addClass('active');
      $('ul.bar_tabs li.tab-shipment').addClass('active');      
      break;
    case 'bill':
      $('#tab_bill').addClass('active');
      $('ul.bar_tabs li.tab-bill').addClass('active');      
      break;
    }

    $.cookie("order_detail_last", '');
  }

  var handleBillTab = function(){
    //Remove bill
    $("#tab_bill a.remove_bill_link").click(function(){
      var r = confirm("Do you want to remove bill?");
      if (r == true) {
        var reqUrl = $(this).data('activity');    
        var data = {};
        do_activity(reqUrl, data, 'bill', 'delete');        
      }
    });
  }

  var handleBillModal = function(){
    // Generate bill From Popup
    $("#bill_modal #btn_create_bill").click(function(){
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
          sub_total: $('#bill_modal #sub_total_cell').text(),
          discount_total: 0,
          tax_total: $('#bill_modal #tax_total_cell').text(),
          shipping_total: '0',
          total: $('#bill_modal #total_cell').text()
      };

      do_activity(reqUrl, data, 'bill');
    });    

    $("#bill_modal #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $("#bill_modal #product_list td.editable").focusout(function(){
      $("#bill_modal #product_list td.editable").removeClass("edit-focus");
      calculateBill();
    });

    $("#bill_modal #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        calculateBill();
        event.preventDefault();
        break;
      }
    });

    $("#bill_modal #paid_amount").keydown(function(event){
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

      var paid = 0;//$( modalId + ' #paid_amount').val();
      change = paid - total;
      $( modalId + ' #sub_total_cell').text(subTotal.toFixed(2));      
      $( modalId + ' #tax_total_cell').text(taxTotal.toFixed(2));
      $( modalId + ' #total_cell').text(total.toFixed(2));
      $( modalId + ' #change_cell').text(change.toFixed(2));
    }

    $(".bill_detail_modal #btn_update_bill").click(function(){
      var billItemData = new Array();
      var modalId = '#' + $(this).parents().find('.bill_detail_modal').attr('id');
      var action_name = ($(this).hasClass('btn-primary')) ? 'update' : 'confirm';

      $( modalId + ' #product_list tbody tr').each(function(row, tr){
        billItemData.push({
          "quantity" : $(tr).find('td:eq(2)').text().trim(),
          "discount" : 0,
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
          // paid: $( modalId + ' #paid_amount').val(),
          sub_total: $( modalId + ' #sub_total_cell').text(),
          discount_total: 0,
          tax_total: $( modalId + ' #tax_total_cell').text(),
          shipping_total: '0',
          total: $( modalId + ' #total_cell').text()
      };
      do_activity(reqUrl, data, 'bill', 'put');
    });    

    $(".bill_detail_modal #product_list td.editable").focus(function(){
      $(this).addClass("edit-focus");
    });

    $(".bill_detail_modal #product_list td.editable").focusout(function(){
      $(this).removeClass("edit-focus");
      var modalId = '#' + $(this).parents().find('.bill_detail_modal').attr('id');
      calculateBill(modalId);
    });

    $(".bill_detail_modal #product_list td.editable").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        var modalId = '#' + $(this).parents().find('.bill_detail_modal').attr('id');
        calculateBill(modalId);
        event.preventDefault();
        break;
      }
    });

    $(".bill_detail_modal #paid_amount").keydown(function(event){
      code = (event.keyCode ? event.keyCode : event.which);
      switch(code) {
      case 13:
        var modalId = '#' + $(this).parents().find('.bill_detail_modal').attr('id');
        calculateBill(modalId);
        event.preventDefault();
        break;
      }
    });

  }

  var handlePurchaseOrderAction = function(){
    /*************** Cancel Action *******************************/
    $('.purchase-order-cancel').click(function(){
      $('#cancel_purchase_order_token').text($(this).data('token'));
      $('#cancel_reason').val('');
      $('#cancel_purchase_order_id').val($(this).data('id'));
    });

    $('#button_cancel_purchase_order').click(function(){      
      var purchase_order_id = $('#cancel_purchase_order_id').val();
      var reqUrl = '/purchase_orders/' + purchase_order_id + '/cancel'
      var purchase_order_token = $('#cancel_purchase_order_token').val();
      var mode = $(this).data('type');
      $.ajax({
        url: reqUrl,
        type: 'post',
        datatype: 'json',
        data: { reason: $('#cancel_reason').val() },
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

  return {
    //main function to initiate the module
    initPurchaseOrderNavList: function () {
      initialNavigatorList();
      rollbackLastAction();
      handlePurchaseOrderAction();
    },

    handleOrderReceiveTab: function() {
      handleReceiveTab();
    },

    handleOrderBillTab: function(){
      handleBillTab();
      handleBillModal();
    }
  };
}();  

