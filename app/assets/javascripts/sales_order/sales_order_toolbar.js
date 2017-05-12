
var SalesOrderToolBar = function(){
  var createPackageList = function(){
    $('.create-package-link').click(function(){
      $('#package_modal').modal();
    });    
  }

  var createShippment = function(){
    $('.create-shippment-link').click(function(){
    });    
  }

  var createInvoice = function(){
    $('.create-invoice-link').click(function(){
    });    
  }

  return {
    handleSalesOrderToolbar: function () {
      createPackageList();
      createShippment();
      createInvoice();
    }
  };
}();