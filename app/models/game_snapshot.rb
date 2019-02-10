class GameSnapshot < ApplicationRecord
  extend GameEnum
  include GameAttributes

  belongs_to :play, optional: true
  delegate :game, to: :play

  delegate :home_team, :visitors, to: :game

  def self.take_snapshot_of(game)
    attrs = game.attributes
    %w(id home_team_id visitors_id).each { |attr_name| attrs.delete(attr_name) }
    new(attrs)
  end

  def no_huddle
    false
  end

  def total_score
    score_home + score_visitors
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
end
