class CreateTeamTraits < ActiveRecord::Migration[5.1]

  def change
    create_table :team_traits do |t|
      t.references :team, foreign_key: true

      t.integer    :run_yardage     , null: false, default: 0
      t.integer    :run_breakaway   , null: false, default: 0
      t.integer    :pass_short      , null: false, default: 0
      t.integer    :pass_long       , null: false, default: 0
      t.integer    :pass_breakaway  , null: false, default: 0
      t.integer    :pass_protect    , null: false, default: 0
      t.integer    :qb_mobility     , null: false, default: 0

      t.integer    :run_defense     , null: false, default: 0
      t.integer    :run_tackling    , null: false, default: 0
      t.integer    :pass_rush       , null: false, default: 0
      t.integer    :pass_coverage   , null: false, default: 0
      t.integer    :pass_tackling   , null: false, default: 0

      t.integer    :place_kicking   , null: false, default: 0
      t.integer    :return_breakaway, null: false, default: 0
      t.integer    :return_coverage , null: false, default: 0

      t.timestamps
    end
  end
end
