# encoding: ISO-8859-1
require 'csv'
File.open("card_names.csv","w") do |f|
	aux = []
	CSV.parse(File.read("card_names_origin.csv")) do |card|
		aux << card.to_s.gsub('"','').gsub('[','').gsub(']','')
	end
	aux.uniq!
	for card in aux do
		f.puts card
	end
end