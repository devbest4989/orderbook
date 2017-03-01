$(document).ready ->
  $.listen 'parsley:field:validate', ->
    validateFront()
    return

  validateFront = ->
    if true == $('#contact_form').parsley().isValid()
      $('.bs-callout-info').removeClass 'hidden'
      $('.bs-callout-warning').addClass 'hidden'
    else
      $('.bs-callout-info').addClass 'hidden'
      $('.bs-callout-warning').removeClass 'hidden'
    return

  jQuery('img.customer-default-avatar').each ->
    $img = jQuery(this)
    imgID = $img.attr('id')
    imgClass = $img.attr('class')
    imgURL = $img.attr('src')
    jQuery.get imgURL, ((data) ->
      # Get the SVG tag, ignore the rest
      $svg = jQuery(data).find('svg')
      # Add replaced image's ID to the new SVG
      if typeof imgID != 'undefined'
        $svg = $svg.attr('id', imgID)
      # Add replaced image's classes to the new SVG
      if typeof imgClass != 'undefined'
        $svg = $svg.attr('class', imgClass + ' replaced-svg')
      # Remove any invalid XML tags as per http://validator.w3.org
      $svg = $svg.removeAttr('xmlns:a')
      # Check if the viewport is set, else we gonna set it if we can.
      if !$svg.attr('viewBox') and $svg.attr('height') and $svg.attr('width')
        $svg.attr 'viewBox', '0 0 ' + $svg.attr('height') + ' ' + $svg.attr('width')
      # Replace image with new SVG
      $img.replaceWith $svg
      return
    ), 'xml'
    return
  $('#btn_add_contact').on 'click', ->
    $('#contact_form').parsley().validate()
    validateFront()
    if true == $('#contact_form').parsley().isValid()
      $.ajax
        url: add_contact_url
        type: 'put'
        datatype: 'json'
        data: $('#contact_form').serialize()
        success: (data) ->
          if data.Result == 'OK'
            new PNotify(
              title: 'Add Contact'
              text: 'Contact information is added successfully.'
              type: 'success')
            itemHtml = '<tr><td>' + data.Records.first_name + ' ' + data.Records.last_name + '</td><td>'
            itemHtml += data.Records.email + '</td><td>'
            itemHtml += data.Records.mobile_number + '</td><td>'
            itemHtml += data.Records.landline_number + '</td><td>'
            itemHtml += data.Records.designation + '</td><td>'
            
            if data.Records.is_default == 1
              labelDefault = 'Default'
            else
              labelDefault = ''

            itemHtml += labelDefault + '</td><td>'
            itemHtml += '<a class="contact-delete btn btn-danger btn-xs" data-id="' + data.Records.id + '" href="#"><i class="fa fa-trash-o"></i></a></td></tr>'
            $('#contact_table tr:last').after itemHtml
          else
            new PNotify(
              title: 'Error - Add Contact'
              text: 'Adding Contact information is failed.'
              type: 'error')
          $('#contact_form input').val ''
          $('#contact_form').parsley().reset()
          $('.bs-contact-add').modal 'toggle'
          return
        error: ->
          new PNotify(
            title: 'Error - Add Contact'
            text: 'Adding Contact information is failed.'
            type: 'error')
          $('#contact_form input').val ''
          $('#contact_form').parsley().reset()
          $('.bs-contact-add').modal 'toggle'
          return
    return
  $('#btn_close_contact').on 'click', ->
    $('#contact_form input').val ''
    $('#contact_form').parsley().reset()
    return
  $(document).on 'click', 'a.contact-delete', ->
    data_id = $(this).attr('data-id')
    $.ajax
      url: '/contacts/' + data_id + '/remove'
      type: 'get'
      success: (data) ->
        if data.Result == 'OK'
          new PNotify(
            title: 'Remove Contact'
            text: 'Contact information is removed successfully.'
            type: 'success')
          $('#contact_table tbody tr').each ->
            if $(this).children('td').children('a').attr('data-id') == data_id
              $(this).remove()
            return
        else
          new PNotify(
            title: 'Error - Remove Contact'
            text: 'Removing Contact information is failed.'
            type: 'error')
        return
      error: ->
        new PNotify(
          title: 'Error - Remove Contact'
          text: 'Removing Contact information is failed.'
          type: 'error')
        return
    event.preventDefault()
    return
  return
