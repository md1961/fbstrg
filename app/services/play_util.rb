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
        no_xp = next2&.game_snapshot&.total_score == score_next ? 'NO ' : ''
        play.scoring = "TOUCHDOWN (XP #{no_xp}GOOD)"
        write_score(6 + (no_xp.blank? ? 1 : 0), play)
      when 3
        play.scoring = 'FIELD GOAL'
        write_score(3, play)
      when 2
        play.scoring = 'SAFETY'
        write_score(2, play)
      end
    end
  end

    def write_score(score, play)
      gss = play.game_snapshot
      if score >= 3 && !play.possession_changing?
        gss.home_has_ball ? gss.score_home += score : gss.score_visitors += score
      else
        gss.home_has_ball ? gss.score_visitors += score : gss.score_home += score
      end
    end
end
