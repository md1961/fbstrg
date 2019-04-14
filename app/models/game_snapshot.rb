class GameSnapshot < ApplicationRecord
  extend GameEnum
  include GameAttributes

  belongs_to :play, optional: true
  delegate :game, to: :play

  delegate :home_team, :visitors, :defense_human?, to: :game

  attr_accessor :result, :offensive_play, :previous_spot, :announcement
  attr_reader :offensive_play_set, :defensive_play, :defensive_play_set

  def self.take_snapshot_of(game)
    attrs = game.attributes
    %w(id home_team_id visitors_id).each { |attr_name| attrs.delete(attr_name) }
    new(attrs)
  end

  def no_huddle
    false
  end

  def hides_offensive_play?
    false
  end

  def hides_defensive_play?
    false
  end

  def total_score
    score_home + score_visitors
  end

  def original_result
    return nil if !offensive_play || !defensive_play
    result_chart = offense.play_result_chart
    result_chart.result(offensive_play, defensive_play)
  end

  def add_points(value, for_offense = true)
    return unless value
    if (home_has_ball && for_offense) || (!home_has_ball && !for_offense)
      self.score_home += value
    else
      self.score_visitors += value
    end
  end

  def attributes_for_game
    attributes.dup.tap { |attrs|
      attrs.delete('id')
      attrs.delete('game_id')
      attrs.delete('play_id')
      attrs.delete('created_at')
      attrs.delete('updated_at')
      attrs['home_team_id'] = game.home_team_id
      attrs['visitors_id' ] = game.visitors_id
    }
  end

  def update_scores_by(game)
    self.score_home     = game.score_home
    self.score_visitors = game.score_visitors
    save!
  end

  def set_plays_and_play_sets_from_result
    @offensive_play     = result.offensive_play
    @offensive_play_set = result.offensive_play_set
    @defensive_play     = result.defensive_play
    @defensive_play_set = result.defensive_play_set
  end
end
