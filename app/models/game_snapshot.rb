class GameSnapshot < ApplicationRecord
  extend GameEnum

  belongs_to :play, optional: true
  delegate :game, to: :play

  delegate :home_team, :visitors, :defense, :timeout_left, :score_diff, :no_huddle, :final_FG_stands?,
           to: :game

  def self.take_snapshot_of(game)
    attrs = game.attributes
    %w(id home_team_id visitors_id).each { |attr_name| attrs.delete(attr_name) }
    new(attrs)
  end

  def goal_to_go?
    100 - ball_on <= yard_to_go
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

  def offense
    home_has_ball ? game.home_team : game.visitors
  end

  def update_scores_by(game)
    self.score_home     = game.score_home
    self.score_visitors = game.score_visitors
    save!
  end
end
