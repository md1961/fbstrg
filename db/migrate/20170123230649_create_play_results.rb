class CreatePlayResults < ActiveRecord::Migration[4.2]

  def change
    create_table :play_results do |t|
      t.references :play_result_chart, index: true, foreign_key: true
      t.references :offensive_play   , index: true, foreign_key: true
      t.references :defensive_play   , index: true, foreign_key: true
      t.string     :result           , null: false

      t.timestamps null: false
    end
  end
end
