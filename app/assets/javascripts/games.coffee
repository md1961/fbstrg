# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('span#toggle_plays_display').click ->
    $('table#play_by_play').toggle()

  $('#strategy_tool_judgments').hide()

  announce = (text, timeout) ->
    new Promise((resolve, reject) ->
      setTimeout(->
        if text == '__END__'
          $('#announce_board').hide()
          $('#information_board').show()
          $('#score_board_prev').hide()
          $('#score_board').show()
          $('#form_command').show()
          $('#strategy_tool_judgments').show()
        else
          $('#announce_board').html(text)
        resolve()
      , timeout
      )
    )

  announcements = $('#announce_board').data('announcements')
  if announcements && announcements.length == 0
    announcements = [['__END__', 0]]
  arrayAnnounces = $.map(announcements, (elem, _) ->
    () ->
      announce(elem[0], elem[1])
  )

  $('#form_command').hide()
  arrayAnnounces.reduce((prev, curr) ->
    prev.then(curr)
  , Promise.resolve()
  )
