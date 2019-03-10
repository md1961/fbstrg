$ ->
  $('.teams_index th.toggle_actions').on 'click', ->
    team_id = $(this).data('team_id')
    $('span.actions.team_' + team_id).toggle()
