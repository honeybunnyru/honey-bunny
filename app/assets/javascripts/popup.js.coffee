$ ->
  if $('.popup-with-form').length
    $('.popup-with-form').magnificPopup
      type: 'inline'
      preloader: false

  $('body').on 'click', '.popup-close', (event) ->
    event.preventDefault()
    $.magnificPopup.instance.close()
    false

  $('.popup-open').each ->
    $(this).magnificPopup
      type: 'inline'
      midClick: true
    return
