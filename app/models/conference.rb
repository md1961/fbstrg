class Conference < TeamGroup

  def league
    parent
  end

  def to_s
    abbr
  end
end
