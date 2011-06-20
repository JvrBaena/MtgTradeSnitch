class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.string :card
      t.string :url
      t.string :average_nonfoil
      t.string :average_foil
      t.timestamps
    end
  end

  def self.down
    drop_table :cards
    drop_table :shops
  end
end
