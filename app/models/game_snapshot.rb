class GameSnapshot < ActiveRecord::Base
  belongs_to :game

  enum next_play: {kickoff: 0, extra_point: 1, scrimmage: 2}
  enum status: {playing: 0, end_of_quarter: 1, end_of_half: 2, end_of_game: 3}

  def self.take_snapshot_of(game)
    attrs = game.attributes
    %w(id home_team_id visitors_id).each { |attr_name| attrs.delete(attr_name) }
    game.game_snapshots.build(attrs)
  end

  def goal_to_go?
    100 - ball_on <= yard_to_go
  end

  def build_game
    attrs = attributes
    attrs.delete('game_id')
    attrs['home_team_id'] = game.home_team_id
    attrs['visitors_id' ] = game.visitors_id
    Game.new(attrs)
  end

  def offense
    home_has_ball ? game.home_team : game.visitors
  end
end
