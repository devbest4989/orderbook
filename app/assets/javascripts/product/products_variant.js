var ProductsVariant = function () {
  var handleNewVariantBlock = function(){
    $('#sub_product_list').hide();
    $('#add_variant').click(function(e){
      var uniq = new Date().getTime();
      var option_name = '';
      switch($('#product_variant_list table tr').length){
      case 1:
        option_name = 'Size';
        break;
      case 2:
        option_name = 'Color';
        break;
      case 3:
        option_name = 'Material';
        break;
      }
      var template = '<tr><td>Option Name</td><td><input class="form-control option-name" name="[variants]['+uniq+'][name]" value="'+option_name+'"></td><td>Option Values</td><td><input class="form-control variant-values" name="[variants]['+uniq+'][value]" id="values_'+uniq+'"></td><td><a href="javascript:;" class="remove-variant"><i class="fa fa-icon fa-trash"></i></a></td></tr>';
      $('#add_variant_block').before(template);
      if($('#product_variant_list table tr').length == 4){
        $(this).hide();
      }

      $('#values_' + uniq).tagsInput({'onChange': onVariantChanged, 'defaultText': 'Input value.'});
      e.preventDefault();
    });

    $('#product_variant_list').on('click', '.remove-variant', function(e){
      $(this).parent().parent().remove();
      if($('#product_variant_list table tr').length < 4){
        $('#add_variant').show();
      }
      onVariantChanged();
    });

    $('#sub_product_list').on('click', 'input.sub-product-selector', function(e){
      if(!$(this).prop('checked')){
        $(this).parent().parent().find('.form-control').each(function(index, elem){
          $(this).prop('disabled', true);
        });
      } else {
        $(this).parent().parent().find('.form-control').each(function(index, elem){
          $(this).removeProp('disabled');
        });
      }
    });
  }

  function onVariantChanged() {
    var option_list = [];
    var option_names = [];
    $('.option-name').each(function(index, item){
      option_names.push($(this).val());
    });

    $('.variant-values').each(function(index, item){
      option_list.push($(this).val().split(','));
    });

    var template = '';
    var uniq = 0;
    var selling_price = $('#product_selling_price').val();
    switch(option_list.length){
      case 1:
        for(var i = 0; i < option_list[0].length; i++){
          var variant_text = option_list[0][i];
          var hidden_values = '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option1]" value="'+option_names[0]+'"> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value1]" value="'+option_list[0][i]+'">';
          hidden_values += '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option2]" value=""> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value2]" value="">';
          hidden_values += '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option3]" value=""> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value3]" value="">';
          template += '<tr><td>'+hidden_values+'<input type="checkbox" class="sub-product-selector" checked></td><td>'+variant_text+'</td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][open_qty]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][sku]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][barcode]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][selling_price]" value="' + selling_price + '"></td></tr>';
          uniq++;
        }
      break;
      case 2:
        for(var i = 0; i < option_list[0].length; i++){
          for(var j = 0; j < option_list[1].length; j++){
            var variant_text = option_list[0][i] + "-" + option_list[1][j];
            var hidden_values = '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option1]" value="'+option_names[0]+'"> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value1]" value="'+option_list[0][i]+'">';
            hidden_values += '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option2]" value="'+option_names[1]+'"> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value2]" value="'+option_list[1][j]+'">';
            hidden_values += '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option3]" value=""> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value3]" value="">';

            template += '<tr><td>'+hidden_values+'<input type="checkbox" class="sub-product-selector" checked></td><td>'+variant_text+'</td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][open_qty]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][sku]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][barcode]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][selling_price]" value="' + selling_price + '"></td></tr>';
            uniq++;
          }
        }
      break;
      case 3:
        for(var i = 0; i < option_list[0].length; i++){
          for(var j = 0; j < option_list[1].length; j++){
            for(var k = 0; k < option_list[2].length; k++){
              var variant_text = option_list[0][i] + "-" + option_list[1][j] + "-" + option_list[2][k];
              var hidden_values = '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option1]" value="'+option_names[0]+'"> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value1]" value="'+option_list[0][i]+'">';
              hidden_values += '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option2]" value="'+option_names[1]+'"> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value2]" value="'+option_list[1][j]+'">';
              hidden_values += '<input type="hidden" class="form-control" name="[sub_product]['+uniq+'][option3]" value="'+option_names[2]+'"> <input type="hidden" class="form-control" name="[sub_product]['+uniq+'][value3]" value="'+option_list[2][k]+'">';
              template += '<tr><td>'+hidden_values+'<input type="checkbox" class="sub-product-selector" checked></td><td>'+variant_text+'</td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][open_qty]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][sku]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][barcode]"></td><td><input type="text" class="form-control" name="[sub_product]['+uniq+'][selling_price]" value="' + selling_price + '"></td></tr>';
              uniq++;
            }
          }
        }
      break;      
    }

    if(template == ''){
      $('#sub_product_list').hide();
    } else {
      $('#sub_product_list').show();
      $('#sub_product_list table tbody').html(template);
    }
  }


  var handleShowVariantBlock = function() {
    $('.variant-values').tagsInput({'onRemoveTag': onVariantRemoved, interactive: false});
  }

  function onVariantRemoved(tag) {
    if(confirm('Do you want to delete the all sub product of ' + tag + ' value?') == true){
      $.ajax({
        url: '/product_variants/'+$(this).data('id')+'/remove_value',
        type: 'post',
        datatype: 'json',
        data: {
          value: $(this).val(),
          tag: tag
        },
        success: function(data){          
          if(data.result = 'OK'){
            window.location.href= data.url;
          }          
        },
        error:function(){
        }   
      });      
    }
    $(this).importTags($(this).data('value'));
  }
  return {
    //main function to initiate the module
    initNewForm: function () {
      handleNewVariantBlock();
    },

    initProductShow: function () {
      handleShowVariantBlock();
    }    
  };
}();