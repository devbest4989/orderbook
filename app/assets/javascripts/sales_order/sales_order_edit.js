
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
        var message = ($('#save_action').val() == 'quote') ? "Do you want to send quote email to customer?"  : "Do you want to send confirmation email to customer?";
        var ret = confirm(message);
        if(ret){
          $('#email_action').val('1');
        } else {
          $('#email_action').val('0');
        }

        var reqData = $('#edit_order_detail_form').serializeArray();
        var reqUrl = "/sales_orders/" + $('#sales_order_id').val();
        $.ajax({
          url: reqUrl,
          type: "post",
          datatype: 'json',
          data: reqData,
          success: function(data){
            if(data.Result == "OK"){
              window.location.href = data.url;
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
