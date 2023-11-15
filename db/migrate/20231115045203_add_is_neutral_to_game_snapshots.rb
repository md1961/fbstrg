class AddIsNeutralToGameSnapshots < ActiveRecord::Migration[5.2]

  def change
    add_column :game_snapshots, :is_neutral, :boolean, null: false, default: false
  end
end
