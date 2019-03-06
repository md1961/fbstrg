# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('span#toggle_plays_display').click ->
    $('table#play_by_play').toggle()
    $('span#toggle_scorings').toggle()

  $('span#toggle_scorings').click ->
    $('.no_scoring').toggle()

  $('span#toggle_stats_display').click ->
    $('div.stats').toggle()

  $('span.toggle_strategy_tool_judgments_display').click ->
    $(this).parents('tr').next('tr').toggle()

  announce = (text, timeout) ->
    new Promise((resolve, reject) ->
      setTimeout(->
        if text == '__END__'
          $('#announce_board').hide()
          $('#information_board').show()
          $('#score_board_prev').hide()
          $('#score_board').show()
          $('#form_command').show()
          $('#judgments_and_plays').show()
          $('div.buttons').show()
        else
          $('#announce_board').html(text)
        resolve()
      , timeout
      )
    )

  announcements = $('#announce_board').data('announcements')
  if announcements
    if announcements.length == 0
      announcements = [['__END__', 0]]
    else
      $('#judgments_and_plays').hide()

  arrayAnnounces = $.map(announcements, (elem, _) ->
    () ->
      announce(elem[0], elem[1])
  )

  arrayAnnounces.reduce((prev, curr) ->
    prev.then(curr)
  , Promise.resolve()
  )
