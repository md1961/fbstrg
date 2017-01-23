class CreatePlayResultCharts < ActiveRecord::Migration

  def change
    create_table :play_result_charts do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
