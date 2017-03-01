var SalesOrdersCommon = function () {

  return {
    initSiderMenuList: function () {
      $('#sidebar-menu li').removeClass('current-page');
      $('#sidebar-menu li').removeClass('active');
      $('#sidebar-menu li.nav-sales-orders').addClass('active');
    }
  };
}();  

var SalesOrdersEdit = function(){
  var initEditOrderDetailForm = function(){
    //$('#customer_id_').editableSelect({ effects: 'slide' });

    $('#order_date').daterangepicker({
      singleDatePicker: true,
      calender_style: "picker_4",
      format: 'YYYY-MM-DD'
    }, function(start, end, label) {
    });

    $('#estimate_ship_date').daterangepicker({
      singleDatePicker: true,
      calender_style: "picker_4",
      format: 'YYYY-MM-DD'
      }, function(start, end, label) {
    });

    $('#sales_order_ship_country').addClass('form-control');
    $('#sales_order_bill_country').addClass('form-control');
  }

  var handleOrderDetail = function(){
    $.listen('parsley:field:validate', function() {
      validateFront('#edit_order_detail_form');
    });

    $('#sales_order_customer_id').on('change', function(e) {
      detail_url = "/customer/detail_info/" + $(this).find('option:selected').val();
      $.ajax({
        url: detail_url,
        type: "post",
        datatype: 'json',
        success: function(data){
          // billing detail
          $('#sales_order_bill_street').val(data.info.bill_street);
          $('#sales_order_bill_suburb').val(data.info.bill_suburb);
          $('#sales_order_bill_state').val(data.info.bill_state);
          $('#sales_order_bill_postcode').val(data.info.bill_postcode);
          $('#sales_order_bill_city').val(data.info.bill_city);
          $('#sales_order_bill_country').val(data.info.bill_country);

          // shipping detail
          $('#sales_order_ship_street').val(data.info.ship_street);
          $('#sales_order_ship_suburb').val(data.info.ship_suburb);
          $('#sales_order_ship_state').val(data.info.ship_state);
          $('#sales_order_ship_postcode').val(data.info.ship_postcode);
          $('#sales_order_ship_city').val(data.info.ship_city);
          $('#sales_order_ship_country').val(data.info.ship_country);

          var contactArray = $.map(data.contacts, function(value, key) {
            return {
              value: value.first_name + " " + value.last_name,
              data: value
            };
          });
          // Initialize autocomplete with custom appendTo:
          $('#sales_order_contact_name').autocomplete({
            lookup: contactArray,
            onSelect: function (suggestion) {
              $('#sales_order_contact_phone').val(suggestion.data.mobile_number);
              $('#sales_order_contact_email').val(suggestion.data.email);
            }                
          });
        },
        error:function(){
        }   
      });
    });

    $('.btn-order-detail').click(function() {      
      if($(this).hasClass('btn-save')){
        $('#save_action').val('quote');
      } else if($(this).hasClass('btn-confirm')){
        $('#save_action').val('confirm');
      }

      var validate = $('#edit_order_detail_form').parsley().validate();
      validateFront('#edit_order_detail_form');
      if(validate === true){
        var reqData = $('#edit_order_detail_form').serializeArray();
        var reqUrl = "/sales_orders/" + $('#sales_order_id').val();
        $.ajax({
          url: reqUrl,
          type: "post",
          datatype: 'json',
          data: reqData,
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
      } else {        
      }
    });
  }

  var validateFront = function(form_id) {
    if (true === $(form_id).parsley().isValid()) {
      $('.bs-callout-info').removeClass('hidden');
      $('.bs-callout-warning').addClass('hidden');
    } else {
      $('.bs-callout-info').addClass('hidden');
      $('.bs-callout-warning').removeClass('hidden');
    }
  };    


  return {
    initEditDetailForm: function () {
      initEditOrderDetailForm();
      handleOrderDetail();
    }
  };  
}();

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
        packItemData.push({
          "quantity" : $(tr).find('td:eq(3)').text().trim(),
          "note" :$(tr).find('td:eq(4)').text().trim(),
          "id" : $(tr).find('td:eq(5)').text().trim()
        });    
      }); 
      var reqUrl = $('#pack_req_url').val();
      var data = {pack_attributes: packItemData};
      do_activity(reqUrl, data, 'pack');
    });    

    //Remove Track
    $("#tab_pack a.remove_track_link").click(function(){
      var reqUrl = $('#pack_remove_url').val();
      var data = {activity: $(this).data('activity'), type: 'pack'};
      do_activity(reqUrl, data, 'pack');
    });    
  }

  var do_activity = function(reqUrl, data, page){
    $.ajax({
      url: reqUrl,
      type: "post",
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
    }

    $.cookie("order_detail_last", '');
  }

  var handleShipTab = function(){
    $('.group-checkable').click(function(){
      if($(this).is(':checked') == true){
        $(".bulk_action input[name='table_records']").prop("checked",true);
      } else {
        $(".bulk_action input[name='table_records']").prop("checked",false);
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
      var data = {pack_tokens: pack_tokens};
      do_activity(reqUrl, data, 'ship');
    });

    //Remove Track
    $("#tab_shipment a.remove_track_link").click(function(){
      var reqUrl = $('#ship_remove_url').val();    
      var data = {activity: $(this).data('activity'), type: 'ship'};
      do_activity(reqUrl, data, 'ship');
    });    

  }

  return {
    //main function to initiate the module
    initSalesOrderNavList: function () {
      initialNavigatorList();
      rollbackLastAction();
    },

    handleOrderPackageTab: function() {
      handlePackageTab();
    },

    handleOrderShipTab: function() {
      handleShipTab();
    }
  };
}();  

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
    initSalesOrderList: function () {
      initialHeader();
      handleOrderBy();
      handleGroupSelect();
    }
  };
}();

var SalesOrdersNew = function () {

  var handleNewFormCommand = function(){
    $('.btn-cancel').click(function(){
      window.location.href= '/sales_orders';
    });

    $('#billing_address_link').click(function(){
      
    });

    $('#shipping_address_link').click(function(){
      
    });
  }

  var initNewForm = function(){
    $('#customer_id_').editableSelect({ effects: 'slide' });

    $('#order_date').daterangepicker({
      singleDatePicker: true,
      calender_style: "picker_4",
      format: 'YYYY-MM-DD'
    }, function(start, end, label) {
    });

    $('#estimate_ship_date').daterangepicker({
      singleDatePicker: true,
      calender_style: "picker_4",
      format: 'YYYY-MM-DD'
      }, function(start, end, label) {
    });


    $('#ship_country_').addClass('form-control');
    $('#bill_country_').addClass('form-control');    
  }

  var handleCustomer = function (){
    $('#customer_id_').on('select.editable-select', function(e, li){
      if(li){
        if(li.val() > 0){
          detail_url = "/customer/detail_info/" + li.val();
          $.ajax({
            url: detail_url,
            type: "post",
            datatype: 'json',
            success: function(data){
              $('#billing_info').html(data.billing);
              $('#shipping_info').html(data.shipping);

              // billing detail
              $('#sales_order_bill_street').val(data.info.bill_street);
              $('#sales_order_bill_suburb').val(data.info.bill_suburb);
              $('#sales_order_bill_state').val(data.info.bill_state);
              $('#sales_order_bill_postcode').val(data.info.bill_postcode);
              $('#sales_order_bill_city').val(data.info.bill_city);
              $('#sales_order_bill_country').val(data.info.bill_country);

              // shipping detail
              $('#sales_order_ship_street').val(data.info.ship_street);
              $('#sales_order_ship_suburb').val(data.info.ship_suburb);
              $('#sales_order_ship_state').val(data.info.ship_state);
              $('#sales_order_ship_postcode').val(data.info.ship_postcode);
              $('#sales_order_ship_city').val(data.info.ship_city);
              $('#sales_order_ship_country').val(data.info.ship_country);

              // billing detail modal
              $('#bill_street').val(data.info.bill_street);
              $('#bill_suburb').val(data.info.bill_suburb);
              $('#bill_state').val(data.info.bill_state);
              $('#bill_postcode').val(data.info.bill_postcode);
              $('#bill_city').val(data.info.bill_city);
              $('#bill_country_').val(data.info.bill_country);

              // shipping detail modal
              $('#ship_street').val(data.info.ship_street);
              $('#ship_suburb').val(data.info.ship_suburb);
              $('#ship_state').val(data.info.ship_state);
              $('#ship_postcode').val(data.info.ship_postcode);
              $('#ship_city').val(data.info.ship_city);
              $('#ship_country_').val(data.info.ship_country);

              data.contacts.forEach(function(elem){
                if(elem.is_default == 1){
                  $('#sales_order_contact_name').val(elem.first_name + " " + elem.last_name);
                  $('#sales_order_contact_phone').val(elem.mobile_number);
                  $('#sales_order_contact_email').val(elem.email);
                }
              });

              $('#sales_order_payment_term').val(data.info.payment_term);
              $('#sales_order_price_name').val(data.info.default_price);

              var contactArray = $.map(data.contacts, function(value, key) {
                return {
                  value: value.first_name + " " + value.last_name,
                  data: value
                };
              });

              // Initialize autocomplete with custom appendTo:
              $('#sales_order_contact_name').autocomplete({
                lookup: contactArray,
                onSelect: function (suggestion) {
                  $('#sales_order_contact_phone').val(suggestion.data.mobile_number);
                  $('#sales_order_contact_email').val(suggestion.data.email);
                }                
              });

            },
            error:function(){
            }   
          });                     
        }        
      }
    });

    $('#btn_bill_save').click(function(){
      // billing detail
      $('#sales_order_bill_street').val($('#bill_street').val());
      $('#sales_order_bill_suburb').val($('#bill_suburb').val());
      $('#sales_order_bill_state').val($('#bill_state').val());
      $('#sales_order_bill_postcode').val($('#bill_postcode').val());
      $('#sales_order_bill_city').val($('#bill_city').val());
      $('#sales_order_bill_country').val($('#bill_country_').val());

      var address = $('#bill_street').val() +  " " + 
                    $('#bill_suburb').val() + " " + 
                    $('#bill_city').val() + " " + 
                    $('#bill_postcode').val() +  " " + 
                    $('#bill_state').val() + " " + 
                    $('#bill_country_ option:selected').text();
      $('#billing_info').html(address);

    });

    $('#btn_ship_save').click(function(){

      // shipping detail
      $('#sales_order_ship_street').val($('#ship_street').val());
      $('#sales_order_ship_suburb').val($('#ship_suburb').val());
      $('#sales_order_ship_state').val($('#ship_state').val());
      $('#sales_order_ship_postcode').val($('#ship_postcode').val());
      $('#sales_order_ship_city').val($('#ship_city').val());
      $('#sales_order_ship_country').val($('#ship_country_').val());

      var address = $('#ship_street').val() +  " " + 
                    $('#ship_suburb').val() + " " + 
                    $('#ship_city').val() + " " + 
                    $('#ship_postcode').val() +  " " + 
                    $('#ship_state').val() + " " + 
                    $('#ship_country_ option:selected').text();
      $('#shipping_info').html(address);
    });
  }

  var handleProductTable = function(){
    
  }

  var handleForm = function(){
    $.listen('parsley:field:validate', function() {
      validateFront();
    });

    var form_id = ($('#sales_order_id').val() == '') ? '#new_sales_order' : '#edit_sales_order_' + $('#sales_order_id').val();

    $('.btn-order').click(function() {      
      if($(this).hasClass('btn-save')){
        $('#save_action').val('save');
      } else {
        $('#save_action').val('confirm');
      }

      var validate = $(form_id).parsley().validate();
      validateFront();
      if(validate === true){
        var reqData = $(form_id).serializeArray();
        reqData.push({name: 'sales_order[customer_id]', value: $('.customer-box .es-list .es-visible').val()});
        reqData.push({name: 'sales_order[total_amount]', value: $('#total_cell').text()});
        tdata = t.serialize();
        for(i = 0; i < tdata.length; i++){
          for(key in tdata[i]){
            item_key = 'sales_order[sales_items_attributes]['+i+']['+key+']';
            reqData.push({name: item_key, value: tdata[i][key]});
          }
        }


        var reqUrl = ($('#sales_order_id').val() == '') ? "/sales_orders" : "/sales_orders/" + $('#sales_order_id').val();
        $.ajax({
          url: reqUrl,
          type: "post",
          datatype: 'json',
          data: reqData,
          success: function(data){
            if(data.Result == "OK"){
              window.location.href = "/sales_orders/all/list_orders";
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
      } else {        
      }
    });
  }

  var validateFront = function() {
    var form_id = ($('#sales_order_id').val() == '') ? '#new_sales_order' : '#edit_sales_order_' + $('#sales_order_id').val();
    if (true === $(form_id).parsley().isValid()) {
      $('.bs-callout-info').removeClass('hidden');
      $('.bs-callout-warning').addClass('hidden');
    } else {
      $('.bs-callout-info').addClass('hidden');
      $('.bs-callout-warning').removeClass('hidden');
    }
  };    

  return {
    handleSalesOrderNewCommand: function () {
      handleNewFormCommand();
    },

    initSalesOrderNewForm: function(){
      initNewForm();
      handleCustomer();
      handleProductTable();
      handleForm();
    }
  };
}();