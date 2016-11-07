$(document).ready ->
  $.listen 'parsley:field:validate', ->
    validateFront()
    return
  $(edit_form + ' .btn').on 'click', ->
    $(edit_form).parsley().validate()
    validateFront()
    return

  validateFront = ->
    if true == $(edit_form).parsley().isValid()
      $('.bs-callout-info').removeClass 'hidden'
      $('.bs-callout-warning').addClass 'hidden'
    else
      $('.bs-callout-info').addClass 'hidden'
      $('.bs-callout-warning').removeClass 'hidden'
    return

  $('#address_substitute').on 'change', ->
    if @checked
      $(type_prefix + '_ship_street').val $(type_prefix + '_bill_street').val()
      $(type_prefix + '_ship_suburb').val $(type_prefix + '_bill_suburb').val()
      $(type_prefix + '_ship_city').val $(type_prefix + '_bill_city').val()
      $(type_prefix + '_ship_country').val $(type_prefix + '_bill_country').val()
      $(type_prefix + '_ship_postcode').val $(type_prefix + '_bill_postcode').val()
      select_wrapper = $('#ship_state_wrapper')
      url = type_preffix_path + '/ship_state?parent_region=' + $(type_prefix + '_ship_country').val()
      select_wrapper.load url, ->
        $('select' + type_prefix + '_ship_state').addClass 'form-control'
        $('select' + type_prefix + '_ship_state').after '<ul class="parsley-errors-list"></ul>'
        $(type_prefix + '_ship_state').val $(type_prefix + '_bill_state').val()
        return
    else
      $(type_prefix + '_ship_street').val ''
      $(type_prefix + '_ship_suburb').val ''
      $(type_prefix + '_ship_city').val ''
      $(type_prefix + '_ship_state').val ''
      $(type_prefix + '_ship_country').val ''
      $(type_prefix + '_ship_postcode').val ''
    return
  $('select' + type_prefix + '_ship_country').addClass 'form-control'
  $('select' + type_prefix + '_ship_state').addClass 'form-control'
  $('select' + type_prefix + '_ship_country').change (event) ->
    country_code = undefined
    select_wrapper = undefined
    url = undefined
    select_wrapper = $('#ship_state_wrapper')
    $('select', select_wrapper).attr 'disabled', true
    country_code = $(this).val()
    url = type_preffix_path + '/ship_state?parent_region=' + $(type_prefix + '_ship_country').val()
    select_wrapper.load url, ->
      $('select' + type_prefix + '_ship_state').addClass 'form-control'
      $('select' + type_prefix + '_ship_state').after '<ul class="parsley-errors-list"></ul>'
      return
    return
  $('select' + type_prefix + '_bill_country').addClass 'form-control'
  $('select' + type_prefix + '_bill_state').addClass 'form-control'
  $('select' + type_prefix + '_bill_country').change (event) ->
    country_code = undefined
    select_wrapper = undefined
    url = undefined
    select_wrapper = $('#bill_state_wrapper')
    $('select', select_wrapper).attr 'disabled', true
    country_code = $(this).val()
    url = type_preffix_path + '/bill_state?parent_region=' + $(type_prefix + '_bill_country').val()
    select_wrapper.load url, ->
      $('select' + type_prefix + '_bill_state').addClass 'form-control'
      $('select' + type_prefix + '_bill_state').after '<ul class="parsley-errors-list"></ul>'
      return
    return
  return

