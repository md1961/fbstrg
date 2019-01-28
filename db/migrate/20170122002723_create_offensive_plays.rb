class CreateOffensivePlays < ActiveRecord::Migration[4.2]

  def change
    create_table :offensive_plays do |t|
      t.integer :number        , null: false
      t.string  :name          , null: false
      t.integer :min_throw_yard
      t.integer :max_throw_yard

      t.timestamps null: false
    end
  end
end
