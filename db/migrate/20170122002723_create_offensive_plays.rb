class CreateOffensivePlays < ActiveRecord::Migration

  def change
    create_table :offensive_plays do |t|
      t.integer :number, null: false
      t.string  :name  , null: false

      t.timestamps null: false
    end
  end
end
