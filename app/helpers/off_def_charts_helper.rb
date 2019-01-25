module OffDefChartsHelper

  def off_def_chart_item_display(offensive_play, defensive_play)
    classes = [@type == 'int' ? 'numeric' : 'centered']
    value = @f_item.call(offensive_play, defensive_play)
    if @type == 'result'
      play = Play.parse(value)
      classes << \
        if play.incomplete?
          value = nil
          'incomplete'
        elsif play.fumble?
          'big_loss'
        elsif (play.on_ground? || play.complete?)
          play.yardage >= 10 ? 'long_gain' : play.yardage > 0 ? 'gain' : 'loss'
        else
          'big_loss'
        end
    end
    content_tag :td, value, class: classes.join(' ')
  end
end
