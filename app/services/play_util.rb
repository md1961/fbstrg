module PlayUtil
  module_function

  def write_scorings(plays)
    (plays.sort_by(&:number) + [nil] * 2).each_cons(3) do |play, next1, next2|
      break unless next1
      score_curr  = play  .game_snapshot .total_score
      score_next1 = next1 .game_snapshot .total_score
      score_next2 = next2&.game_snapshot&.total_score
      next unless score_next1 > score_curr
      case score_next1 - score_curr
      when 6
        next1.extra_point! if score_next2 && score_next2 > score_next1
        play.touchdown!
      when 3
        play.field_goal!
      when 2
        play.safety!
      end
    end
  end
end
