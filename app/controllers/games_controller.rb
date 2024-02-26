class GamesController < ApplicationController
  before_action :set_game, only: [:show, :update]

  def index
    league = League.find_by(id: params[:league_id])
    @games = Game.all.find_all { |g| g.schedule&.league == league }
    @games.sort_by! { |g| g.schedule || g.created_at }
  end

  def show
    if params[:two_point_try] == 'true'
      session[:offensive_play_id] = nil
      @game.two_point_try = true
      @game.ball_on = 98
      @game.huddle!
    else
      offensive_play_id = session[:offensive_play_id]
      @game.offensive_play = OffensivePlay.find(offensive_play_id) if offensive_play_id
      @play_id_to_show_details = params[:play_id_to_show_details].to_i
    end

    @offensive_play_id_in_session = session[:offensive_play_id]
  end

  def update
    @game.no_huddle = (params[:no_huddle] == 'true') || session[:no_huddle]
    @game.two_point_try = (params[:two_point_try] == 'true') || session[:two_point_try]
    @game.ball_on = 98 if @game.two_point_try

    @game_snapshot_prev = nil
    if params[:play] == 'to_final_minutes'
      @game.to_final_minutes!
    elsif params[:play] == 'revert'
      begin
        @game.revert!
      rescue => e
        @game.error_message = e.to_s
      end
    elsif Game.tampering_game?(params[:play])
      @game.tamper(params[:play])
    elsif @game.final?
      if @game.playoff?
        @game.league&.eliminate_loser_in!(@game)
      end
    elsif @game.end_of_quarter? || @game.end_of_half?
      if session[:next_quarter]
        @game.advance_to_next_quarter
        @game.save!
        session[:next_quarter] = nil
      else
        session[:next_quarter] = true
      end
    elsif @game.huddle?
      @game.determine_offensive_play(params[:play]).tap do |play|
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
      if %w[cancel <].include?(params[:play]) || !@game.offensive_play
        @game.cancel_offensive_play
        render :show and return
      elsif params[:play] =~ /\A\d{1,3}\z/ && @game.offense_human_assisted?
        session[:offensive_play_id] = @game.determine_offensive_play(params[:play])&.id
        render :show and return
      elsif params[:play] =~ /\A[a-j]+\z/i && @game.defense_human_assisted?
        begin
          play = DefensivePlay.pick_from(params[:play].upcase)
          @game.defensive_play = play
          @game.defensive_play_set = nil
          session[:defensive_play_id]     = play&.id
          session[:defensive_play_set_id] = nil
        rescue Exceptions::IllegalResultStringError => e
          @game.error_message = e.message
        end
        render :show and return
      end

      @game.play(params[:play])

      if @game.error_message.blank?
        session[:offensive_play_id] = nil
        @game.save!
        @game.no_huddle = false
        session[:no_huddle] = false
      end
      if @game.two_point_try
        redirect_to game_path(@game, two_point_try: true) and return
      elsif @game.result.is_a?(Play)
        game_snapshot_prev = @game.game_snapshots.order(:play_id).last
        @game_snapshot_prev = game_snapshot_prev&.dup
      end
      #game_snapshot_prev.update_scores_by(@game)
    end

    @game.remove_announcement if !@game.human_assisted? && @no_announce
    render :show
  end

  def replay
    play = Play.find(params[:play_id])
    @game_snapshot_prev = play.game_snapshot
    next_play = play.game.plays.where("number > ?", play.number).order(:number).first
    @game = next_play&.game_snapshot || GameSnapshot.take_snapshot_of(play.game).tap { |gss| gss.play = play }
    @game.result = play
    @game.set_plays_and_play_sets_from_result
    @game.announcement = Announcer.announce(play)
    @replay = true
    render :show
  end

  def new
    redirect_to Game.create!
  end

  private

    def set_game
      begin
        @game = Game.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        redirect_to games_path
      end
    end
end
