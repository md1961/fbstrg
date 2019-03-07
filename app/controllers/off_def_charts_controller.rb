class OffDefChartsController < ApplicationController

  DEFAULT_TYPE = 'result'
  TYPES = [DEFAULT_TYPE, 'int', 'sack', 'fumble', 'breakaway']

  def index
    @type = params[:type]
    redirect_to off_def_charts_path(type: DEFAULT_TYPE) if @type.blank?
    offensive_play_scope, @f_item = \
      case @type
      when 'int'
        [
          :pass_plays,
          ->(offensive_play, defensive_play) {
            Play.pct_intercept_base(offensive_play, defensive_play)
          }
        ]
      when 'sack'
        [
          :pass_plays,
          ->(offensive_play, defensive_play) {
            Play.pct_sack_base(offensive_play, defensive_play)
          }
        ]
      when 'fumble'
        play = Play.new
        [
          :normal_plays,
          ->(offensive_play, defensive_play) {
            play.result = offensive_play.run? ? :on_ground : :complete
            play.send(:pct_fumble_base, offensive_play, defensive_play)
          }
        ]
      when 'breakaway'
        play = Play.new
        [
          :normal_plays,
          ->(offensive_play, defensive_play) {
            play.result = offensive_play.run? ? :on_ground : :complete
            play.send(:pct_breakaway_base, offensive_play, defensive_play)
          }
        ]
      else
        [
          :normal_plays,
          ->(offensive_play, defensive_play) {
            PlayResultChart.find_by(name: 'Pro style (revised)').result(offensive_play, defensive_play)
          }
        ]
      end
    @offensive_plays = OffensivePlay.send(offensive_play_scope)
    @defensive_plays = DefensivePlay.all
  end
end
