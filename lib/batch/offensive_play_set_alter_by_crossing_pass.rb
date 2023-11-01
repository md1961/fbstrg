exit

crossing_pass    = OffensivePlay.crossing_pass
button_hook_pass = OffensivePlay.button_hook_pass
razzle_dazzle    = OffensivePlay.razzle_dazzle

OffensivePlaySet.all.each do |offensive_play_set|
  choice = offensive_play_set.offensive_play_set_choices.find_by(offensive_play: crossing_pass)
  offensive_play_set.offensive_play_set_choices.create!(offensive_play: razzle_dazzle, weight: choice.weight)
  choice_b = offensive_play_set.offensive_play_set_choices.find_by(offensive_play: button_hook_pass)
  choice.update!(weight: choice_b.weight)
end
