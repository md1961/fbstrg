module OffDefChartsHelper

  def off_def_chart_item_display(offensive_play, defensive_play)
    classes = []
    value = @f_item.call(offensive_play, defensive_play)
    if @type != 'result'
      classes << 'numeric'
      value = value.zero? ? '-' : "%5.1f" % value
    else
      classes << 'centered' << \
        if value == 'incmp'
          value = nil
          'incomplete'
        elsif value.starts_with?('fmb')
          'fumble'
        elsif value.starts_with?('sck')
          'sacked'
        else
          yardage = value.sub(/^cmp/, '').to_i
          value.ends_with?('long') ? 'long_gain' : yardage >= 10 ? 'good_gain' : yardage > 0 ? 'gain' : 'loss'
        end
    end
    content_tag :td, value, class: classes.join(' ')
  end
end
