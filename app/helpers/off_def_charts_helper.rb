module OffDefChartsHelper

  def off_def_chart_item_display(offensive_play, defensive_play)
    classes = []
    value = @f_item.call(offensive_play, defensive_play)
    case @type
    when 'int', 'sack'
      classes << 'numeric'
      value = value.zero? ? '-' : "%5.1f" % value
    else
      play = Play.parse(value, offensive_play)
      classes << 'centered' << \
        if play.incomplete?
          value = nil
          'incomplete'
        elsif play.fumble?
          'fumble'
        elsif (play.on_ground? || play.complete?)
          play.yardage >= 10 ? 'long_gain' : play.yardage > 0 ? 'gain' : 'loss'
        else
          'sacked'
        end
    end
    content_tag :td, value, class: classes.join(' ')
  end
end
