class CreateMagicCardMarketScrappers < ActiveRecord::Migration
  def self.up
    create_table :magic_card_market_scrappers do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :magic_card_market_scrappers
  end
end
