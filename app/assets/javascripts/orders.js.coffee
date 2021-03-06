$ ->

  increment = (button) ->
    $form = $(button).closest('form')
    $input = $form.find('input.js-order-item-quantity')
    value = $input.val()
    if /^\d+$/.test(value)
      $input.val(parseInt(value) + 1)
      $form.submit()

  decrement = (button) ->
    $form = $(button).closest('form')
    $input = $form.find('input.js-order-item-quantity')
    value = $input.val()
    if /^\d+$/.test(value)
      value = parseInt(value) - 1
      if value >= 0
        $input.val(value)
        $form.submit()

  # Filters cities list by current shipping method
  filterCitiesByShippingMethod = ->
    options = $(cities).filter("option[data-shipping-method-#{currentShippingMethod().val()}]")
    $('.js-order-city').html(options).trigger("chosen:updated")

  # Updates shipping methods with subtitles for current city
  updateShippingMethodSubtitles = ->
    $("input.js-order-shipping-method-id").each (index, shippingMethod) ->
      if $(shippingMethod).data('rate-type') is 'individual'
        $(shippingMethod).closest('label').find('span.price').text("+ X руб.")
      else
        price = shippingPriceFor(shippingMethod, currentCity())

        unless price is undefined
          if $(shippingMethod).attr('title') != 'Курьер по Москве'
            $(shippingMethod).closest('label').find('span.price').text("#{humanizedMoney(price)} руб.")
        # if currentShippingMethodName() == 'Курьер по Москве' and window.totalItemsPrice > 1000
        #  price = 0
        # else
        #  unless price is undefined
        #    if $(shippingMethod).attr('title') != 'Курьер по Москве'
        #      $(shippingMethod).closest('label').find('span.price').text("#{humanizedMoney(price)} руб.")

  currentShippingMethodName = ->
    $("input.js-order-shipping-method-id:checked").attr('title')

  # Updates order total price value as sum of items price and shipping price
  window.updateTotalDiscount = (discount)->
    window.totalDiscount = discount.amount
    if discount.kind == 'value'
      window.DiscountPercent = false
    else
      window.DiscountPercent = true

  window.updateTotalPrice = ->
    #itemsPrice = parseFloat($('#order-items-price').text().toString().replace(' ', ''))
    if window.DiscountPercent
      itemsPrice = window.totalItemsPrice - (window.totalItemsPrice * window.totalDiscount / 100)
    else
      itemsPrice = window.totalItemsPrice - window.totalDiscount
    itemsPrice = 0 if itemsPrice < 0
    shippingPrice = parseFloat(currentShippingPrice().toString().replace(' ', '')) || 0

    $("input.js-order-shipping-method-id:checked").closest('label').find('span.price').text(shippingPrice+" руб.")
    if currentShippingMethodName() == 'Курьер по Москве' and itemsPrice > 1499
     shippingPrice = 0
     $("input.js-order-shipping-method-id:checked").closest('label').find('span.price').text(shippingPrice+" руб.")
    else
     $("input.js-order-shipping-method-id:checked").closest('label').find('span.price').text(shippingPrice+" руб.")

    totalPrice = humanizedMoney(itemsPrice + shippingPrice)

    $('#order-items-price').text(humanizedMoney(itemsPrice))
    $('#order-total-price').text(totalPrice)

  $("#discount_code").on "change", ->
    self = $(@)
    http.post('/check_discount', {discount_code: self.val(), items_price: window.totalItemsPrice}).done((data) ->
      $('.js-discount-id').val(data.id)
      self.closest('.field').find('.message').text('')
      updateTotalDiscount(data)
      updateTotalPrice()
      return
    ).error((data) ->
      data = JSON.parse(data.responseText)
      $('.js-discount-id').val('')
      self.closest('.field').find('.message').text(data.error)
      window.totalDiscount = 0
      window.DiscountPercent = false
      updateTotalPrice()
    )

  currentCity = ->
    value = $('.js-order-city').val()
    $(".js-order-city option[value='#{value}']")

  currentShippingMethod = ->
    $("input.js-order-shipping-method-id:checked")

  currentPaymentMethod = ->
    $("input.js-order-payment-method-id:checked")

  currentShippingPrice = ->
    shippingPriceFor(currentShippingMethod(), currentCity()) || ""

  shippingPriceFor = (shippingMethod, city) ->
    $(city).data("shipping-method-#{$(shippingMethod).val()}")

  humanizedMoney = (money) ->
    str = money.toString().split('.')
    if str[0].length >= 4
        str[0] = str[0].replace(/(\d)(?=(\d{3})+$)/g, '$1 ')
    if str[1] && str[1].length >= 4
        str[1] = str[1].replace(/(\d{3})/g, '$1 ')
    str.join('.')

  if $('#new_order').length
    $("input.js-order-shipping-method-id").on 'change', ->
      $('.js-order-shipping-info-fields').toggle($("input.js-order-shipping-method-id:checked").val() is '2')

  # Initialize scripts on /orders/new and /wholesale_orders/new pages
  if $('#new_order').length or $('#new_wholesale_order').length
    # Full list of cities. It could be filtered by data-shipping-method-* attribute
    cities = $('.js-order-city').html()

    # Setup input masks
    $('.js-order-phone').mask('+7 (999) 999-99-99')

    filterCitiesByShippingMethod()
    updateShippingMethodSubtitles()
    updateTotalPrice()

    # Callback on city select
    $('.js-order-city').on 'change', ->
      updateShippingMethodSubtitles()
      updateTotalPrice()

    # Callback on shipping method change
    $("input.js-order-shipping-method-id").on 'change', ->
      filterCitiesByShippingMethod()
      updateShippingMethodSubtitles()
      updateTotalPrice()

    $('.js-order-item a.plus').on 'click', (event) ->
      event.preventDefault()
      increment(this)
      false

    $('.js-order-item a.minus').on 'click', (event) ->
      event.preventDefault()
      decrement(this)
      false

    $('input.js-order-item-quantity').on 'focusout', (event) ->
      $(this).closest('form').submit()

  # Initialize scripts on /wholesale_orders/new page
  if $('#new_wholesale_order').length
    # Callback on shipping method change
    $("input.js-order-shipping-method-id").on 'change', ->
      # Show or hide address and additional summary
      $('.js-order-shipping-info-fields').toggle(currentShippingMethod().data('name') == 'transport_company')
      $('.js-transport-company-additional-summary').toggle(currentShippingMethod().data('name') == 'transport_company')

      # Change contact info title
      $title = $('.js-contact-info-title')
      title = if currentShippingMethod().data('name') == 'own_expense'
        $title.data('own-expense')
      else
        $title.data('transport-company')
      $title.text(title)

    # Callback on payment method change
    $("input.js-order-payment-method-id").on 'change', ->
      $submitButton = $('.js-submit-button')
      title = if currentPaymentMethod().data('name') == 'cash'
        $submitButton.data('cash')
      else
        $submitButton.data('w1')
      $submitButton.text(title)
