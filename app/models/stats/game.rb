module Stats

class Game
  attr_reader :stats_home, :stats_visitors

  def initialize(game)
    @game = game
    @stats_home      = Stats::Team.new(game.home_team)
    @stats_visitors  = Stats::Team.new(game.visitors )
    tally
  end

  private

    def tally
      plays = @game.plays.includes(:game_snapshot)
      plays.each do |play|
        stat = play.game_snapshot.home_has_ball ? @stats_home : @stats_visitors
        stat.tally_from(play)
      end

      @stats_home    .set_defense_stats(@stats_visitors)
      @stats_visitors.set_defense_stats(@stats_home    )
    end
end

end
