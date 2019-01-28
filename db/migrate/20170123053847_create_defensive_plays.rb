class CreateDefensivePlays < ActiveRecord::Migration[4.2]

  def change
    create_table :defensive_plays do |t|
      t.string :name        , null: false
      t.string :lineman     , null: false
      t.string :linebacker  , null: false
      t.string :cornerback  , null: false
      t.string :safety      , null: false
      t.string :against_run , null: false
      t.string :against_pass, null: false

      t.timestamps null: false
    end
  end
end
