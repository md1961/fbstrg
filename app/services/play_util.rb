module PlayUtil
  module_function

  def write_scorings(plays)
    (plays.sort_by(&:number) + [nil] * 2).each_cons(3) do |play, next1, next2|
      break unless next1
      score_curr = play .game_snapshot.total_score
      score_next = next1.game_snapshot.total_score
      next unless score_next > score_curr
      case score_next - score_curr
      when 6
        play.scoring = 'TOUCHDOWN'
      when 3
        play.scoring = 'FIELD GOAL'
      when 2
        play.scoring = 'SAFETY'
      end
    end
  end
end
