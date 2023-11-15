class AddIsPlayoffToSchdules < ActiveRecord::Migration[5.2]

  def change
    add_column :schedules, :is_playoff, :boolean, null: false, default: false
  end
end
