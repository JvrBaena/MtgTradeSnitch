class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :shops do |t|
      t.string :name
      t.timestamps
    end
    create_table :cards do |t|
      t.string :card
      t.string :expansion
      t.string :price
      t.string :condition
      t.references :shop
      t.timestamps
    end
  end

  def self.down
    drop_table :cards
    drop_table :shops
  end
end
