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
      format: 'DD-MM-YYYY'
    }, function(start, end, label) {
    });

    $('#estimate_ship_date').daterangepicker({
      singleDatePicker: true,
      calender_style: "picker_4",
      format: 'DD-MM-YYYY'
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


              $('#sales_order_contact_name').val(data.info.first_name + " " + data.info.last_name);
              $('#sales_order_contact_phone').val(data.info.phone);
              $('#sales_order_contact_email').val(data.info.email);

              // data.contacts.forEach(function(elem){
              //   if(elem.is_default == 1){
              //     $('#sales_order_contact_name').val(elem.first_name + " " + elem.last_name);
              //     $('#sales_order_contact_phone').val(elem.mobile_number);
              //     $('#sales_order_contact_email').val(elem.email);
              //   }
              // });

              $('#sales_order_payment_term_id').val(data.info.payment_term_id);
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
        var ret = confirm("Do you want to send confirmation email to customer?");
        if(ret){
          $('#email_action').val('1');
        } else {
          $('#email_action').val('0');
        }

        var reqData = $(form_id).serializeArray();
        reqData.push({name: 'sales_order[customer_id]', value: $('.customer-box .es-list .es-visible').val()});
        reqData.push({name: 'sales_order[total_amount]', value: $('#total_cell').text()});
        
        tdata = serializeProductTable();
        for(i = 0; i < tdata.length; i++){
          for(key in tdata[i]){
            item_key = 'sales_order[sales_items_attributes]['+i+']['+key+']';
            reqData.push({name: item_key, value: tdata[i][key]});
          }
        }

        t_custom_data = serializeCustomProductTable();
        for(i = 0; i < t_custom_data.length; i++){
          for(key in t_custom_data[i]){
            if(key != 'sold_item_id'){
              item_key = 'sales_order[sales_custom_items_attributes]['+i+']['+key+']';
              reqData.push({name: item_key, value: t_custom_data[i][key]});                          
            }
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

  var serializeProductTable = function(){
    var data = [];
    var rows = $("#product_item_list tbody > tr");

    $(rows).each(function () {

        var row = {};

        $(this).children("td").each(function () {

            var field = $(this).children("input").data('field');

            if(field != '' && field != undefined){
                row[field] = $(this).children("input").val();
            }
        });

        if(row['sold_item_id'] > 0){
          data.push(row);
        }        
    });  
    return data;
  }

  var serializeCustomProductTable = function(){
    var data = [];
    var rows = $("#product_item_list tbody > tr");

    $(rows).each(function () {

        var row = {};

        $(this).children("td").each(function () {

            var field = $(this).children("input").data('field');

            if(field != '' && field != undefined){
                row[field] = $(this).children("input").val();
            }
        });

        if(row['sold_item_id'] == -1){
          data.push(row);
        }        
    });  
    return data;
  }


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
