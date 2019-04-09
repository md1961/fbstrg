module Stats

class KickoffReturn < Return

  def to_be_tallied?(play)
    play.kickoff_and_return? && yardage_from(play) > 0
  end
end

end
