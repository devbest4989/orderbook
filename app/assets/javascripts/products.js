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
      $('.action-box').show();
    else 
      $('.action-box').hide();
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
    $('#warehouse_name').editableSelect({ effects: 'slide' });    

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
      calculatePercents(4);
    });

    $('#product_selling_tax_id').change(function(){
      calculateSellingPrice();
    });

    $('#selling_price_table').on('change', '.sell-price', function(){
      calculateSellingPrice();
    });

    $('#selling_price_table').on('change', '.mp-percent', function(){
      calculatePercents(3);
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

  var calculateSellingPrice = function (percent = true){
    var tax_string = $('#product_selling_tax_id option:selected').text();
    var tax_rate = tax_string.substring(tax_string.lastIndexOf('-') + 2, tax_string.length -1);
    if(!$('#product_selling_price_type').is(':checked')){
      var exclude_price = $('#product_selling_price').val()/(1 + tax_rate * 0.01);
      $('#product_selling_price_ex').val(exclude_price.toFixed(2));
    } else {
      var include_price = $('#product_selling_price_ex').val()*(1 + tax_rate * 0.01);
      $('#product_selling_price').val(include_price.toFixed(2));
    }

    if(percent) calculatePercents(2);
  }    

  var switchPurchasePrice = function (){
    if(!$('#product_purchase_price_type').is(':checked')){
      $('.purchase_exclude_tax').hide();
      $('.purchase_include_tax').show();
    } else {
      $('.purchase_exclude_tax').show();
      $('.purchase_include_tax').hide();
    }

    calculatePercents(1);    
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

    calculatePercents(1);
  }    

  var handleImageUploader = function (){
    var btnCust = '<button type="button" class="btn btn-default" title="Add picture tags" ' + 
      'onclick="alert(\'Call your custom code here.\')">' +
      '<i class="glyphicon glyphicon-tag"></i>' +
      '</button>'; 
    var product_image_url = ($('#product_image_url').val() == '' ) ? '/images/nothumb.png' : $('#product_image_url').val();
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
      defaultPreviewContent: '<img src="'+product_image_url+'" alt="Product Picture" style="max-width: 200px;max-height: 200px;"><h6 class="text-muted">Click to select</h6>',
      layoutTemplates: {main2: '{preview}  {remove} {browse}'},
      allowedFileExtensions: ["jpg", "png", "gif"]
    });      
  }

  var handleTaxChecker = function(){
    $('.js-switch').on('change', function(){
      var target = $(this).data('target');
      if($(this).is(':checked')){
        //$(target).html('Excluding Tax');
      } else {
        //$(target).html('Including Tax');
      }
    });
  }

  var calculatePercents = function(type){
    var purchase_price = ($('.purchase-tax-checkbox').is(':checked')) ? ($('#product_purchase_price_ex').val()) : ($('#product_purchase_price').val());
    if(purchase_price == 0 || purchase_price == '') return;

    purchase_price = parseFloat(purchase_price);

    $('.sell-price-row').each(function(){
      if($(this).find('.sell-price').val() == '' && $(this).find('.mp-percent').val() == ''){
        return;
      }

      switch (type){
      case 1: // change purchase
        if($(this).find('.sell-price').val() == ''){
          var mp_percent = parseFloat($(this).find('.mp-percent').val());
          var selling_price = (purchase_price * (mp_percent / 100)) + purchase_price;
          var gp_percent = (selling_price - purchase_price) * 100 / selling_price;

          $(this).find('.sell-price').val(selling_price.toFixed(2));
          $(this).find('.gp-percent').val(gp_percent.toFixed(2));
        } else {
          var selling_price = parseFloat($(this).find('.sell-price').val());
          var mp_percent = (selling_price - purchase_price) * 100 / purchase_price;
          var gp_percent = (selling_price - purchase_price) * 100 / selling_price;

          $(this).find('.mp-percent').val(mp_percent.toFixed(2));
          $(this).find('.gp-percent').val(gp_percent.toFixed(2));        
        }
        break;
      case 2: // change sell
        var selling_price = parseFloat($(this).find('.sell-price').val());
        var mp_percent = (selling_price - purchase_price) * 100 / purchase_price;
        var gp_percent = (selling_price - purchase_price) * 100 / selling_price;

        $(this).find('.mp-percent').val(mp_percent.toFixed(2));
        $(this).find('.gp-percent').val(gp_percent.toFixed(2));        
        break;
      case 3: // change mp
        var mp_percent = parseFloat($(this).find('.mp-percent').val());
        var selling_price = (purchase_price * (mp_percent / 100)) + purchase_price;
        var gp_percent = (selling_price - purchase_price) * 100 / selling_price;

        $(this).find('.sell-price').val(selling_price.toFixed(2));
        $(this).find('.gp-percent').val(gp_percent.toFixed(2));
        calculateSellingPrice( false );
        break;
      case 4: // change including switch
        var tax_string = $('#product_selling_tax_id option:selected').text();
        var tax_rate = tax_string.substring(tax_string.lastIndexOf('-') + 2, tax_string.length -1);
        if($(this).find('.sell-price').attr('id') == 'product_selling_price' || $(this).find('.sell-price').attr('id') == 'product_selling_price_ex')
          return;
        var original_price = parseFloat($(this).find('.sell-price').val());
        if($('#product_selling_price_type').is(':checked')){
          var exclude_price = original_price /(1 + tax_rate * 0.01);
          $(this).find('.sell-price').val(exclude_price.toFixed(2));
        } else {
          var include_price = original_price*(1 + tax_rate * 0.01);
          $(this).find('.sell-price').val(include_price.toFixed(2));
        }

        var selling_price = parseFloat($(this).find('.sell-price').val());
        var mp_percent = (selling_price - purchase_price) * 100 / purchase_price;
        var gp_percent = (selling_price - purchase_price) * 100 / selling_price;

        $(this).find('.mp-percent').val(mp_percent.toFixed(2));
        $(this).find('.gp-percent').val(gp_percent.toFixed(2));        

        break;
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

var ProductDetail = function () {
  var initialNavigatorList = function(){
    $('#sidebar-menu li').removeClass('current-page');
    $('#sidebar-menu li').removeClass('active');
    $('#sidebar-menu li.nav-products').addClass('active');
    $('#sidebar-menu li.nav-products ul.child_menu li').removeClass('current-page');
    $('#sidebar-menu li.nav-products ul.child_menu li:nth-child(1)').addClass('current-page');
    $('#sidebar-menu li.nav-products ul.child_menu').show();

    $('#product_side_menu').mCustomScrollbar({theme:"minimal-dark", scrollbarPosition: "outside"});    

    var active_elem = 'li.' + $('#active_elem').data('elem') + ' a';
    $(active_elem).addClass('nav-active');    
    $('#product_side_menu').mCustomScrollbar("scrollTo", active_elem);
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

  return {
    //main function to initiate the module
    initProductNavList: function () {
      initialNavigatorList();
    },

    initProductOverview: function(){
      calculateOverviewPercents();
    }
  };
}();  