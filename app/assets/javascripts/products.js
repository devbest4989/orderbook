var Products = function () {

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
      updateSelectedRecordLabel();
    });

    $(".bulk_action input[name='table_records']").click(function(){
      updateSelectedRecordLabel();
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

  var updateSelectedRecordLabel = function() {
    var n = $(".bulk_action input[name='table_records']:checked").length;
    if( n > 0)
      $('.selected-record').html(n + ' Records Selected');
    else 
      $('.selected-record').html('');    
  }

  var initialListPage = function() {
    $('#sidebar-menu li').removeClass('current-page');
    $('#sidebar-menu li').removeClass('active');
    $('#sidebar-menu li.nav-products').addClass('active');
    $('#sidebar-menu li.nav-products ul.child_menu li').removeClass('current-page');
    $('#sidebar-menu li.nav-products ul.child_menu li:nth-child(1)').addClass('current-page');
    $('#sidebar-menu li.nav-products ul.child_menu').show();    
  }

  var initialNewForm = function(){
    $('#category_name').editableSelect({ effects: 'slide' });
    $('#product_line_name').editableSelect({ effects: 'slide' });
    $('#brand_name').editableSelect({ effects: 'slide' });

    switchSellingPrice();
    switchPurchasePrice();

    $('.purchase .js-switch').change(function(){
      switchPurchasePrice();
    });

    $('#product_purchase_tax_id').change(function(){
      calculatePurchasePrice();
    });

    $('#product_purchase_price').change(function(){
      calculatePurchasePrice();
    });

    $('#product_purchase_price_ex').change(function(){
      calculatePurchasePrice();
    });

    $('.selling .js-switch').change(function(){
      switchSellingPrice();
    });

    $('#product_selling_tax_id').change(function(){
      calculateSellingPrice();
    });

    $('#product_selling_price').change(function(){
      calculateSellingPrice();
    });

    $('#product_selling_price_ex').change(function(){
      calculateSellingPrice();
    });

    $('.add-sell-price').on('click', function(){
      $('.additional-price').editableSelect({ effects: 'slide' });      
    });
  }

  var switchSellingPrice = function (){
    if(!$('#product_selling_price_type').is(':checked')){
      $('.selling_exclude_tax').hide();
      $('.selling_include_tax').show();
    } else {
      $('.selling_exclude_tax').show();
      $('.selling_include_tax').hide();
    }    
  }

  var calculateSellingPrice = function (){
    var tax_string = $('#product_selling_tax_id option:selected').text();
    var tax_rate = tax_string.substring(tax_string.lastIndexOf('-') + 2, tax_string.length -1);
    if(!$('#product_selling_price_type').is(':checked')){
      var exclude_price = $('#product_selling_price').val()/(1 + tax_rate * 0.01);
      $('#product_selling_price_ex').val(exclude_price.toFixed(2));
    } else {
      var include_price = $('#product_selling_price_ex').val()*(1 + tax_rate * 0.01);
      $('#product_selling_price').val(include_price.toFixed(2));
    }
  }    

  var switchPurchasePrice = function (){
    if(!$('#product_purchase_price_type').is(':checked')){
      $('.purchase_exclude_tax').hide();
      $('.purchase_include_tax').show();
    } else {
      $('.purchase_exclude_tax').show();
      $('.purchase_include_tax').hide();
    }    
  }

  var calculatePurchasePrice = function (){
    var tax_string = $('#product_purchase_tax_id option:selected').text();
    var tax_rate = tax_string.substring(tax_string.lastIndexOf('-') + 2, tax_string.length -1);
    if(!$('#product_purchase_price_type').is(':checked')){
      var exclude_price = $('#product_purchase_price').val()/(1 + tax_rate * 0.01);
      $('#product_purchase_price_ex').val(exclude_price.toFixed(2));
    } else {
      var include_price = $('#product_purchase_price_ex').val()*(1 + tax_rate * 0.01);
      $('#product_purchase_price').val(include_price.toFixed(2));
    }
  }    

  var handleImageUploader = function (){
    var btnCust = '<button type="button" class="btn btn-default" title="Add picture tags" ' + 
      'onclick="alert(\'Call your custom code here.\')">' +
      '<i class="glyphicon glyphicon-tag"></i>' +
      '</button>'; 
    $("#product_image").fileinput({
      overwriteInitial: true,
      maxFileSize: 2000,
      showClose: false,
      showCaption: false,
      showBrowse: false,
      browseOnZoneClick: true,
      removeLabel: '',
      removeIcon: '<i class="glyphicon glyphicon-remove"></i>',
      removeTitle: 'Cancel or reset changes',
      elErrorContainer: '#kv-avatar-errors',
      msgErrorClass: 'alert alert-block alert-danger',
      defaultPreviewContent: '<img src="/images/nothumb.png" alt="Product Picture" style="width:200px"><h6 class="text-muted">Click to select</h6>',
      layoutTemplates: {main2: '{preview} ' +  btnCust + ' {remove} {browse}'},
      allowedFileExtensions: ["jpg", "png", "gif"]
    });      
  }

  var handleTaxChecker = function(){
    $('.js-switch').on('change', function(){
      var target = $(this).data('target');
      if($(this).is(':checked')){
        $(target).html('Excluding Tax');
      } else {
        $(target).html('Including Tax');
      }
    });
  }

  return {
    //main function to initiate the module
    initProductList: function () {
      initialHeader();      
      handleOrderBy();
      handleGroupSelect();
    },

    initProductListPage: function(){
      initialListPage();
    },

    initProductNewForm: function(){
      initialNewForm();
      handleImageUploader();
      handleTaxChecker();
    }
  };
}();