module TeamsHelper

  def team_trait_display(team_trait, trait_name, value_last = nil)
    return nil unless team_trait

    value = team_trait.send(trait_name).then { |v| v > 0 ? "+#{v}" : v }
    classes = [[nil, :positive, :negative][value.to_i <=> 0]]
    if value_last
      classes << [nil, :increased, :decreased][value.to_i <=> value_last.to_i]
    end

    content_tag :span, class: classes.compact.join(' ') do
      value.to_s
    end
  end

  def team_rating_names
    %w[
      run_offense_rating pass_offense_rating
      run_defense_rating pass_defense_rating
      offense_rating defense_rating total_rating
    ]
  end
end
