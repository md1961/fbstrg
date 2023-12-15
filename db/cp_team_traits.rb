exit

League.find(8).teams.each do |team|
  team0 = League.find(6).teams.detect { |t| t.name == team.name }
  next unless team0
  #p team0.name
  next if team0.team_trait
  tt = team.team_trait.dup
  tt.team_id = team0.id
  tt.save!
end
