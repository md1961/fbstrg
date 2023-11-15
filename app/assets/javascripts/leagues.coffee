$ ->
  $('#toggle_teams').on 'click', ->
    $('div.team_traits').toggle()

  $('table.standing').on 'click', ->
    $(this).closest('div.standing').find('.rank').toggle()
