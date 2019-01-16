# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('span#toggle_plays_display').click ->
    $('table#play_by_play').toggle()

  announce = (text, timeout) ->
    new Promise((resolve, reject) ->
      setTimeout(->
        $('#debug').html(text)
        resolve()
      , timeout
      )
    )

  announcements = $('#information_board').data('announcements')

  arrayAnnounces = $.map(announcements, (elem, _) ->
    announce(elem[0], elem[1])
  )

  arrayAnnounces.reduce((prev, curr) ->
    prev.then(curr)
  , Promise.resolve()
  )
