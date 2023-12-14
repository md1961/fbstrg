class TeamTrait < ApplicationRecord
  belongs_to :team

  def run_offense_rating
    rating_weighted([run_yardage, run_breakaway].zip([80, 20]))
  end

  def pass_offense_rating
    rating_weighted(
      [pass_short, pass_long, pass_breakaway, pass_protect, qb_read] # qb_mobility
        .zip([20, 30, 10, 20, 20])
    )
  end

  def run_defense_rating
    rating_weighted([run_defense, run_tackling].zip([80, 20]))
  end

  def pass_defense_rating
    rating_weighted([pass_rush, pass_coverage, pass_tackling].zip([30, 50, 20]))
  end

  def special_team_rating
    # place_kicking return_breakaway return_coverage
  end

  def offense_rating
    (run_offense_rating * 40 + pass_offense_rating * 60) / 100
  end

  def defense_rating
    (run_defense_rating * 40 + pass_defense_rating * 60) / 100
  end

  def total_rating
    (offense_rating * 50 + defense_rating * 50 ) / 100
  end

  private

    def rating_weighted(trait_names_zip_with_weights)
      trait_names_zip_with_weights.map { |value, weight|
        rating_of(value) * weight
      }.sum / 100
    end

    def rating_of(value)
      (value - -5) * 10
    end
end
