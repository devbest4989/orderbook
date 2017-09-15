var PurchaseOrdersProductTable = function () {

  var handleProductTable = function(){ 
    // $('#product_item_list').on('keydown', 'td .item-name.row-0', function(event){
    //   var code = (event.keyCode ? event.keyCode : event.which);
    //   switch(code) {
    //     case 13:
    //     case 9:
    //       event.stopPropagation();
    //       return false;
    //       break;
    //   }
    // });

    $('#product_item_list').on('keydown', 'td .product-field', function(event){      
      var code = (event.keyCode ? event.keyCode : event.which);
      var row_class = '.row-' + $(this).data('row');
      switch(code) {
        case 13:
        case 9:
          if($(this).hasClass('item-qty')){
            $(row_class + '.item-price').focus().select();
          } else if($(this).hasClass('item-price')){
            $(row_class + '.item-tax').focus().select();
          } else if($(this).hasClass('item-tax')){
          } else if($(this).hasClass('custom-item-name')){
            $(row_class + '.item-qty').focus().select();
          }
          calculateLineAmount(this);
          event.stopPropagation();
          return false;
          break;
      }
    });

    $('.add-custom-product').click(function(e){
      addNewCustomProductLine();
    });
  } 

  var calculateLineAmount = function(item){
    var row_name = '.row-' + $(item).data('row');
    var qty = $('.item-qty'+row_name).val();
    var price = $('.item-price'+row_name).val();
    var discount = 0;
    var tax = $('.item-tax'+row_name).val();

    var amount = qty * price;

    var line_name = '#product_row_' + $(item).data('row');
    $(line_name + ' .line-total').text(amount.toFixed(2));

    calculateTotalAmount();
  }

  var calculateTotalAmount = function(){
    var sub_total = 0, discount_total = 0, tax_total = 0, total = 0;
    $('#product_item_list .product-row').each(function(index, elem){
      var row_number = $(elem).attr('id').replace('product_row_', '');

      var row_name = '.row-' + row_number;
      var qty = $('.item-qty'+row_name).val();
      var price = $('.item-price'+row_name).val();
      var discount = 0;
      var tax = $('.item-tax'+row_name).val();
      var discount_value  = 0.0;

      sub_total += qty * price;
      
      discount_value = 0;
      discount_total = 0;

      tax_total += tax * qty * price * 0.01;
    });

    total += sub_total + tax_total;
    $("td#sub_total_cell").text(sub_total.toFixed(2));
    $("td#tax_total_cell").text(tax_total.toFixed(2));
    $("td#total_cell").text(total.toFixed(2));
  }

  var addNewProductLine = function(){
    var row_number = ($('#product_item_list tbody tr').length > 1) ? $($('#product_item_list tbody tr')[$('#product_item_list tbody tr').length - 2]).attr('id').replace('product_row_', '') : 0;
    row_number++;
    var row_class = 'row-' + row_number;
    var row_id = 'product_row_' + row_number;
    var product_id = $('#product_row_0 .item-id.row-0').val();

    $('.row-0').addClass(row_class);
    $('.row-0').attr('data-row', row_number);
    $('.'+row_class).removeClass('row-0');

    var removeTemplate ='<a href="javascript:;" data-product-row="#'+row_id+'"><i class="fa fa-icon fa-trash"></i></a>';
    $('#product_row_0 td.product-action').html(removeTemplate);
    $('#product_row_0').attr('id', row_id);

    addProductBlankLine();

    $.ajax({
      url: "/products/list_purchase_by_id",
      type: 'POST',
      datatype: 'json',
      data: {
        id: product_id
      },
      success: function(data){
        var price_data = data.product.purchase_price_ex;
        $('.'+row_class+'.item-price').val(price_data);
        $('.'+row_class+'.item-tax').val(data.tax.rate);
      },
      error:function(){
        $('td#'+namecell).empty().text('');
      }   
    });
  }

  var addNewCustomProductLine = function(){
    var row_number = ($('#product_item_list tbody tr').length > 1) ? $($('#product_item_list tbody tr')[$('#product_item_list tbody tr').length - 2]).attr('id').replace('product_row_', '') : 0;
    row_number++;
    var row_class = 'row-' + row_number;
    var row_id = 'product_row_' + row_number;
    var product_id = $('#product_row_0 .item-id.row-0').val();

    var customNameTemplate = '<input class="form-control row-0 product-field custom-item-name" data-row="0" data-field="item_name" type="text" data-parsley-required value="">';
    $('#product_row_0 td.product-name').html(customNameTemplate);
    $('#product_row_0 .custom-item-name.row-0').focus().select();
    $('#product_row_0 .item-id.row-0').val("-1");

    $('.row-0').removeAttr('readonly');
    $('.row-0').addClass(row_class);
    $('.row-0').attr('data-row', row_number);
    $('.'+row_class).removeClass('row-0');

    var removeTemplate ='<a href="javascript:;" data-product-row="#'+row_id+'"><i class="fa fa-icon fa-trash"></i></a>';
    $('#product_row_0 td.product-action').html(removeTemplate);
    $('#product_row_0').attr('id', row_id);

    addProductBlankLine();    
  }

  var removeProductLine = function(){
    $('#product_item_list').on('click', 'td.product-action a', function(event){
      var row_id = $(this).data('product-row');
      $(row_id).remove();
      calculateTotalAmount();
    });
  }

  var initProductList = function(){
    $('#product_row_0 select.item-name').selectize({
        valueField: 'id',
        labelField: 'name',
        searchField: 'name',
        highlight: false,
        create: false,
        render: {
            option: function(item, escape) {
                return '\
                  <div class="search-item">\
                    <i class="category-icon fa fa-cube fa-icon"></i>\
                    <div class="indent-wrap"><span class="title">' + item.name + '</span>\
                      <div class="details">\
                        ' + item.sku + ' | ' + item.brand + ' | ' + item.category + '\
                      </div>\
                    </div>\
                    <div class="available"><span>'+item.quantity+'</span> Available</div>\
                  </div>';
            }
        },
        onChange: function(value){
          if(value != ''){
            $('.row-0').removeAttr('readonly');
          }
          $('.item-qty.row-0').focus().select();
          $('#product_row_0 select.item-name').hide();
          $('#product_row_0 td.product-name').text($('#product_row_0 select.item-name').text());          
          $('#product_row_0 .item-id.row-0').val(value);

          $.ajax({
              url: '/product_by_id',
              type: 'POST',
              data: {
                id: value
              },
              dataType: 'json',
              error: function() {
                $('#product_row_0 td.available-qty').html('');
              },
              success: function(res) {
                $('#product_row_0 td.available-qty').html(res.product.quantity + '<br/>Available');
                addNewProductLine();
              }
          });          
        },
        load: function(query, callback) {
            if (!query.length) return callback();
            $.ajax({
                url: '/product_search',
                type: 'POST',
                data: {
                  key: query
                },
                dataType: 'json',
                error: function() {
                    callback();
                },
                success: function(res) {
                    callback(res.products);
                }
            });
        }
    });    
  }

  var addProductBlankLine = function(){
    var template = '\
        <tr id="product_row_0" class="product-row">\
          <td class="product-name" width="35%" style="min-width: 400px;">\
            <select class="row-0 product-field item-name"></select>\
          </td>\
          <td>\
            <input class="form-control row-0 product-field item-qty text-right" data-row="0" readonly data-field="quantity" type="text" data-parsley-type="number" value="0">\
          </td>\
          <td class="text-center available-qty">\
          </td>\
          <td>\
            <input class="form-control row-0 product-field item-price text-right" data-row="0" readonly data-field="unit_price" type="text" data-parsley-type="number" value="0">\
          </td>\
          <td>\
            <input class="form-control row-0 product-field item-tax text-right" data-row="0" readonly data-field="tax_rate" type="text" data-parsley-type="number" value="0">\
          </td>\
          <td class="line-total money" width="15%" style="min-width: 100px;"></td>\
          <td class="product-action">\
          </td>\
          <td><input class="form-control row-0 product-field item-id" data-row="0" data-field="purchased_item_id" type="hidden" value="0">\
          </td>\
        </tr>';
    $('#product_item_list tbody').append(template);
    initProductList();
  }

  return {
    initProductTable: function(){
      handleProductTable();
      addProductBlankLine();
      removeProductLine();
    }
  };
}();