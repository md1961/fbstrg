class CuiAutoPlayer

  def initialize(game)
    @game = game
  end

  def play
    @game.huddle! if @game.playing?
    session = {}
    while !@game.final?
      @game.no_huddle = session[:no_huddle]
      if @game.end_of_quarter? || @game.end_of_half?
        @game.advance_to_next_quarter
        @game.save!
      elsif @game.huddle?
        @game.determine_offensive_play(@game.next_play).tap do |play|
          session[:offensive_play_id]     = play&.id
          session[:offensive_play_set_id] = @game.offensive_play_set&.id
          session[:no_huddle] = @game.no_huddle
        end
        @game.determine_defensive_play.tap do |play|
          session[:defensive_play_id]     = play&.id
          session[:defensive_play_set_id] = @game.defensive_play_set&.id
        end
      else
        @game.offensive_play     = OffensivePlay   .find_by(id: session[:offensive_play_id])
        @game.offensive_play_set = OffensivePlaySet.find_by(id: session[:offensive_play_set_id])
        @game.defensive_play     = DefensivePlay   .find_by(id: session[:defensive_play_id])
        @game.defensive_play_set = DefensivePlaySet.find_by(id: session[:defensive_play_set_id])
        @game.play(@game.next_play)
        if @game.error_message.present?
          puts @game.error_message
          break
        else
          session[:offensive_play_id] = nil
          @game.save!
          @game.no_huddle = false
          session[:no_huddle] = false

          mins = @game.time_left / 60
          time_left_display = format("%d:%02d", mins, @game.time_left - mins * 60)
          print "#{@game.quarter}Q #{time_left_display}"
          print " #{@game.visitors.abbr} #{@game.score_visitors} - #{@game.home_team.abbr} #{@game.score_home}"
          ball_on = @game.ball_on
          ball_on_prefix = ball_on == 50 ? '' : ball_on < 50 ? 'Own ' : 'Opp '
          ball_on = 100 - ball_on if ball_on > 50

          play = @game.result
          if !play.is_a?(Play) || play.no_scoring?
            print "  #{@game.offense.abbr} on #{ball_on_prefix}#{ball_on}"
            print ' ' * 40 + "\r"
          else
            print "  #{play}"
            print ' ' * 40 + "\r"
            gets
          end
        end
      end
    end
    puts
  end
end
