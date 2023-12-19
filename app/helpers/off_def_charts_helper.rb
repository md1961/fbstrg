module OffDefChartsHelper

  def off_def_chart_item_display(offensive_play, defensive_play)
    value = @f_item.call(offensive_play, defensive_play)
    pct_comp = nil
    classes = []
    if @type != 'result'
      classes << 'numeric'
      value = value.zero? ? '-' : "%5.2f" % value
    else
      value = value.sub('..', ' ~ ').sub('ob', ' *')
      classes << 'centered' << \
        if value == 'incmp'
          value = nil
          'incomplete'
        elsif value.starts_with?('fmb')
          'fumble'
        elsif value.starts_with?('sck')
          'sacked'
        elsif value =~ /\A(100|\d{1,2})%(.*)\z/
          pct_comp = $1.to_i
          value = $2
          pct_comp > 50 ? 'good_gain' : pct_comp > 25 ? 'gain' : 'incomplete'
        else
          yardage = value.sub(/^cmp/, '').to_i
          value.ends_with?('long') ? 'long_gain' : yardage >= 10 ? 'good_gain' : yardage > 0 ? 'gain' : 'loss'
        end
    end
    clazz = classes.join(' ')
    items = [value]
    items.unshift("#{pct_comp}%") if pct_comp
    safe_join(items.map { |v| content_tag :td, v, class: clazz, colspan: 3 - items.size })
  end
end
