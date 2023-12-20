class TeamTraitManager

  def initialize(game, offensive_play = nil)
    @offense_trait = game.offense.team_trait
    @defense_trait = game.defense.team_trait
    @offensive_play = offensive_play
    @home_has_ball = game.home_has_ball
    @is_neutral_game = game.is_neutral
  end

  def place_kicking_factor
    @offense_trait.place_kicking
  end

  def pass_protect_factor
    @offense_trait.pass_protect - @defense_trait.pass_rush - home_defense_factor
  end

  def run_breakaway_factor
    @offense_trait.run_breakaway - @defense_trait.run_tackling - home_defense_factor
  end

  def pass_breakaway_factor
    @offense_trait.pass_breakaway - @defense_trait.pass_tackling - home_defense_factor
  end

  def qb_mobility_factor
    @offense_trait.qb_mobility - @defense_trait.run_tackling - home_defense_factor
  end

  def return_breakaway_factor
    @defense_trait.return_breakaway - @offense_trait.return_coverage
  end

  def run_yardage_factor
    # (1 .. 20) - home_defense_factor
    @offense_trait.run_yardage - @defense_trait.run_defense + 10 - home_defense_factor
  end

  # TODO: Consider to reduce pass_complete_factor.
  def pass_complete_factor
    multiplier = @offensive_play.short_pass? ? 5.0 : @offensive_play.medium_pass? ? 4.0 : 3.0
    (pass_offense_factor - @defense_trait.pass_coverage - home_defense_factor) * multiplier
  end

  def pass_yardage_factor
    defense_factor = rand(2).zero? ? @defense_trait.pass_coverage : @defense_trait.pass_tackling
    pass_offense_factor - defense_factor - home_defense_factor
  end

  def pass_interception_factor
    # -10 .. 10 => 0.0 .. 2.0
    f = pass_offense_factor - @defense_trait.pass_coverage - home_defense_factor
    [f * -0.1 + 1.0, 0.1].max
  end

  def qb_read_factor
    @offense_trait.qb_read - home_defense_factor
  end

  private

    # Home field advantage is in effect in (the ratio below to 1).
    HOME_FIELD_ADVANTAGE_RATIO = 8

    def home_defense_factor
      return 0 if @is_neutral_game || @home_has_ball
      rand(HOME_FIELD_ADVANTAGE_RATIO).zero? ? 1 : 0
    end

    def pass_offense_factor
      @pass_offense_factor ||= \
        if @offensive_play.short_pass? || (@offensive_play.medium_pass? && rand(2).zero?)
          @offense_trait.pass_short
        else
          @offense_trait.pass_long
        end
    end
end
