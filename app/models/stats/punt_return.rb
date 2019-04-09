module Stats

class PuntReturn < Return

  def to_be_tallied?(play)
    play.punt_and_return? && yardage_from(play) > 0
  end
end

end
