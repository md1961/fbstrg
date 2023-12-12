module TeamsHelper

  def team_trait_display(team_trait, trait_name)
    return nil unless team_trait
    team_trait.send(trait_name).then { |v| v > 0 ? "+#{v}" : v }
  end
end
