class Division < TeamGroup

  def league
    conference.league
  end

  def conference
    parent
  end

  def to_s
    [conference, name].join(' ')
  end
end
