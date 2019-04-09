module Stats

class IntReturn < Return

  def to_be_tallied?(play)
    play.intercepted? && yardage_from(play) > 0
  end
end

end
