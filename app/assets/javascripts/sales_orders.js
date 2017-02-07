var SalesOrdersCommon = function () {

  return {
    initSiderMenuList: function () {
      $('#sidebar-menu li').removeClass('current-page');
      $('#sidebar-menu li').removeClass('active');
      $('#sidebar-menu li.nav-sales-orders').addClass('active');
    }
  };
}();  

var SalesOrdersNew = function () {

  var handleNewFormCommand = function(){
    $('.btn-cancel').click(function(){
      window.location.href= '/sales_orders';
    });

    $('.btn-save').click(function(){
      $('#new_sales_order').submit();
    });
  }

  var initNewForm = function(){
    $('#sales_order_customer_id').editableSelect({ effects: 'slide' });

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
    
  }

  var handleCustomer = function (){
    $('#sales_order_customer_id').on('select.editable-select', function(e, li){
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
            },
            error:function(){
            }   
          });                     
        }        
      }
    });
  }

  return {
    handleSalesOrderNewCommand: function () {
      handleNewFormCommand();
    },

    initSalesOrderNewForm: function(){
      initNewForm();
      handleCustomer();
    }
  };
}();  