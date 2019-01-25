module OffDefChartsHelper

  def off_def_chart_item_display(offensive_play, defensive_play)
    clazz = @type == 'int' ? 'numeric' : 'centered'
    value = @f_item.call(offensive_play, defensive_play)
    content_tag :td, value, class: clazz
  end
end
