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
      format: 'YYYY-MM-DD'
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