class AddIsNeutralToGames < ActiveRecord::Migration[5.2]

  def change
    add_column :games, :is_neutral, :boolean, null: false, default: false
  end
end
