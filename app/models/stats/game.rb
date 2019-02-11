module Stats

class Game
  attr_reader :stats_home_team, :stats_visitors

  def initialize(game)
    @game = game
    @stats_home_team = Stats::Team.new(game.home_team)
    @stats_visitors  = Stats::Team.new(game.visitors )
    tally
  end

  private

    def tally
      plays = @game.plays.includes(:game_snapshot)
      PlayUtil.write_scorings(plays)
      plays.each do |play|
        stat = play.game_snapshot.home_has_ball ? @stats_home_team : @stats_visitors
        stat.tally_from(play)
      end
    end
end

end
