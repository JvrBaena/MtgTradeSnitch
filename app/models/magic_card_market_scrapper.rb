class MagicCardMarketScrapper
	
	def self.search(doc)
		result ={}
		several = doc.css('.SearchTable') if doc.present? #tag de varios
		if several.present?
			cols = %w[card expansion rarity link]
			trs = doc.css('.SearchTable tr')
			versions = trs.collect do |tr|
				props = {}
				tr.children.each do |td|
					props[cols[0]] = td.at_css('a').text if td.at_css('a').present?
					props[cols[1]] = td.at_css('.expansionIcon').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if td.at_css('.expansionIcon').present?
					props[cols[2]] = td.at_css('.icon')["alt"] if td.at_css('.icon').present?
					props[cols[3]] = td.at_css('a')["href"] if td.at_css('a').present?
				end
				props
			end
			versions << "" #APAÑO HASTA QUE SAQUEMOS VERSIÓN NUEVA!!!!
			result["several"]= several
			result["versions"]= versions
		else
			cols = %w[seller condition lang foil signed price comments]
			trs = doc.css('tr .hoverator')
			prices = trs.collect do |tr|
				props ={}
				tr.children.each do |td|
					props[cols[0]] = td.at_css('.horListItem  a').content if td.at_css('.horListItem a').present?
					props[cols[1]] = td.at_css('a .icon').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if (td.at_css('a .icon').present? && td.at_css('a .icon').has_attribute?("onmouseover"))
					props[cols[2]] = td.at_css('.flagIcon').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if td.at_css('.flagIcon').present?
					props[cols[3]] = td.xpath('img[@src="http://serv1.tcgimages.eu/img/foil.png"]').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if td.xpath('img[@src="http://serv1.tcgimages.eu/img/foil.png"]').present?
					props[cols[4]] = td.xpath('img[@src="http://serv1.tcgimages.eu/img/signed.png"]').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if td.xpath('img[@src="http://serv1.tcgimages.eu/img/signed.png"]').present?
					props[cols[5]] = td.content if td.has_attribute?("class") && (td["class"] == "alignRight nowrap" || td["class"] == "alignRight nowrap topRow" || td["class"] == "alignRight nowrap bottomRow" || td["class"] == "alignRight nowrap topRow bottomRow")
					props[cols[6]] = td.content if !td.has_attribute?("class") || td["class"] == "topRow" || td["class"] == "bottomRow" || td["class"] == "topRow bottomRow"

				end
				props
			end
			img = doc.css('.prodImage img').present? ? doc.css('.prodImage img').last["src"] : "http://tcgimages.eu/img/cardImageNotAvailable.jpg"
			
			result["prices"]= prices
			result["img"]= img
		end
		query = doc.at_css('.nameHeader').text if doc.at_css('.nameHeader').present?
		result["query"]= query
		
		result
	end
	
	
end
