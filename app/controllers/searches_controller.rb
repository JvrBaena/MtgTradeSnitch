require 'open-uri'
class SearchesController < ApplicationController
	def average
		doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/?mainPage=showSearchResult&searchFor=#{CGI.escape (params[:query])}&searchSingles=Y"))
		hits = doc.css('.navBarTable .virgin') #tag de varios
		cards = doc.css('.alignRight')
		@average = cards.inject(0.0){|res,element| res + element.content.gsub("\u20AC","").gsub(",",".").to_f}/cards.size
		
		
	end
	
	def index
		
		if(params[:url].present?)
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/#{CGI.escape(params[:url])}"))
		else
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/?mainPage=showSearchResult&searchFor=#{CGI.escape (params[:query])}&searchSingles=Y"))
		end
		
		@several = doc.css('.navBarTable .virgin') if doc.present? #tag de varios
		if @several.present?
			cols = %w[card expansion rarity link]
			trs = doc.css('.mainFrame .outerRight .nestedContent tr')
			@versions = trs.collect do |tr|
				props = {}
				tr.children.each do |td|
					props[cols[0]] = td.at_css('a').text if td.at_css('a').present?
					props[cols[1]] = td.at_css('.expansionIcon')["alt"] if td.at_css('.expansionIcon').present?
					props[cols[2]] = td.at_css('.icon')["alt"] if td.at_css('.icon').present?
					props[cols[3]] = td.at_css('a')["href"] if td.at_css('a').present?
				end
				props
			end
		else
			cols = %w[seller condition lang foil signed price]
			trs = doc.css('tr .hoverator')
			@prices = trs.collect do |tr|
				props ={}
				tr.children.each do |td|
					props[cols[0]] = td.at_css('.horListItem  a').content if td.at_css('.horListItem a').present?
					props[cols[1]] = td.at_css('a .icon').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if (td.at_css('a .icon').present? && td.at_css('a .icon').has_attribute?("onmouseover"))
					props[cols[2]] = td.at_css('.flagIcon').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if td.at_css('.flagIcon').present?
					props[cols[3]] = td.xpath('img[@src="http://serv1.tcgimages.eu/img/foil.png"]').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if td.xpath('img[@src="http://serv1.tcgimages.eu/img/foil.png"]').present?
					props[cols[4]] = td.xpath('img[@src="http://serv1.tcgimages.eu/img/signed.png"]').attribute('onmouseover').value.gsub("showMsgBox('",'').gsub("')",'') if td.xpath('img[@src="http://serv1.tcgimages.eu/img/signed.png"]').present?
					props[cols[5]] = td.content if td.has_attribute?("class") && (td["class"] == "alignRight nowrap" || td["class"] == "alignRight nowrap topRow" || td["class"] == "alignRight nowrap bottomRow")
				end
				props
			end
			@img = doc.css('.bottomRow .darkBorder').present? ? doc.css('.bottomRow .darkBorder').last["src"] : "http://tcgimages.eu/img/cardImageNotAvailable.jpg"
		end
		@query = doc.at_css('.nameHeader').text if doc.at_css('.nameHeader').present?
		
		respond_to do |format|
			format.html
			format.json do
				if @several.present?
					render :json => @versions
				else
					render :json => @prices
				end
			end
		end
		
	end
end
