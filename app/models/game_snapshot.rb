class GameSnapshot < ActiveRecord::Base
  belongs_to :game

  def self.take_snapshot_of(game)
    attrs = game.attributes
    %w(id home_team_id visitors_id).each { |attr_name| attrs.delete(attr_name) }
    game.game_snapshots.build(attrs)
  end
end
