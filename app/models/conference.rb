class Conference < TeamGroup

  def league
    parent
  end

  def divisions
    child_groups
  end

  def to_s
    abbr
  end
end
