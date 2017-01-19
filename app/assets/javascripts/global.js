jQuery(document).ready(function() {
  $("input:checkbox").uniform();
});

function add_fields(link, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    if ($(link).hasClass('add-sell-price')) {      
      $(link).parent().parent().parent().find('.selling-tax-box').before(content.replace(regexp, new_id));
    }
}

