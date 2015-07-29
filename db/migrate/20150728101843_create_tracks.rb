class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.string :title
      t.string :artist
      t.decimal :duration, precision: 6, scale: 2
      t.string :date
      t.string :album
      t.string :genre
      t.string :language
      t.string :description
      t.boolean :instrumental, null: false, default: false
      t.boolean :cover, null: false, default: false

      t.timestamps null: false
    end
  end
end
