class GameSnapshot < ActiveRecord::Base
  belongs_to :game

  def self.take_snapshot_of(game)
    attrs = game.attributes
    %w(id home_team_id visitors_id).each { |attr_name| attrs.delete(attr_name) }
    game.game_snapshots.build(attrs)
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
