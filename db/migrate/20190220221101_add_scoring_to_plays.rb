class AddScoringToPlays < ActiveRecord::Migration[5.1]

  def change
    add_column :plays, :scoring, :integer, null: false, default: 0, limit: 1
  end
end
