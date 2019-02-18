class TeamTraitManager

  def initialize(game, offensive_play = nil)
    @offense_trait = game.offense.team_trait
    @defense_trait = game.defense.team_trait
    @offensive_play = offensive_play
  end

  def place_kicking_factor
    @offense_trait.place_kicking + home_factor
  end

  def pass_protect_factor
    @offense_trait.pass_protect - @defense_trait.pass_rush + home_factor
  end

  def run_breakaway_factor
    @offense_trait.run_breakaway - @defense_trait.run_tackling + home_factor
  end

  def pass_breakaway_factor
    @offense_trait.pass_breakaway - @defense_trait.pass_tackling + home_factor
  end

  def return_breakaway_factor
    @offense_trait.return_breakaway - @defense_trait.return_coverage + home_factor
  end

  def run_yardage_factor
    # (1 .. 20) + home_factor
    @offense_trait.run_yardage - @defense_trait.run_defense + 10 + home_factor
  end

  def pass_complete_factor
    multiplier = @offensive_play.short_pass? ? 5.0 : @offensive_play.medium_pass? ? 4.0 : 3.0
    (pass_offense_factor - @defense_trait.pass_coverage + home_factor) * multiplier
  end

  def pass_yardage_factor
    defense_factor = rand(2).zero? ? @defense_trait.pass_coverage : @defense_trait.pass_tackling
    pass_offense_factor - defense_factor + home_factor
  end

  private

    def home_factor
      rand(10).zero? ? 1 : 0
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