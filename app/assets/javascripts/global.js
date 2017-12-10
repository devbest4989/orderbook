jQuery(document).ready(function() {
  $("input:checkbox").uniform();
});

function add_fields(link, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    if ($(link).hasClass('add-sell-price')) {
      $(link).parent().parent().parent().find('.selling-tax-box').before(content.replace(regexp, new_id));
    } else if($(link).hasClass('add-attribute')){
      $('#attribute_table').append(content.replace(regexp, new_id));
    }
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");

  if ($(link).hasClass('remove-sell-price')) {
  	$(link).parent().parent().remove();
  } else if($(link).hasClass('remove-attribute')){
    $(link).parent().parent().remove();
  }
  return false;
}
