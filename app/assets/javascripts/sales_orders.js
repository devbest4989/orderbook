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
  }

  return {
    handleSalesOrderNewCommand: function () {
      handleNewFormCommand();
    },

    initSalesOrderNewForm: function(){
      initNewForm();
    }
  };
}();  