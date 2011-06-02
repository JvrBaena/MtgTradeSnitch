require 'open-uri'
class SearchesController < ApplicationController
	def average
		if(params[:url].present?)
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/#{CGI.escape(params[:url])}"))
		else
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/?mainPage=showSearchResult&searchFor=#{CGI.escape (params[:id])}&searchSingles=Y"))
		end
		result = MagicCardMarketScrapper.search(doc)
		
		@several = result["several"]
		if @several.present?
			@versions = result["versions"]
			@prices = result["prices"]
		else
			@query = result["query"]
			@img = result["img"]
			@average = result["prices"].inject(0.0) do |res,element| 
				element["foil"].nil? ? res + element["price"].gsub("\u20AC","").gsub(",",".").to_f : res + 0
			end
			@average_foil = result["prices"].inject(0.0) do |res,element| 
				element["foil"].present? ? res + element["price"].gsub("\u20AC","").gsub(",",".").to_f : res + 0
			end
			
			nonfoils = 0
			foils = 0
			result["prices"].each do |element| 
			 if element["foil"].present?
			   foils+=1
		   else
		     nonfoils+=1
	     end
			end
      
      @average = nonfoils != 0 ? @average/nonfoils : 0 
			@average_foil = foils != 0 ? @average_foil/foils : 0  

			@average = (@average * 100).round.to_f / 100
			@average_foil = (@average_foil * 100).round.to_f / 100
			
			@average = "N/A" if @average == 0.0
			@average_foil = "N/A" if @average_foil == 0.0
			
		end
		respond_to do |format|
			format.html
			format.json do
				if @several.present?
					render :json => @versions
				else
					render :json => @average
				end
			end
			format.xml do
				if @several.present?
					render :xml => {:versions => @versions}
				else
					render :xml => {:average => @average , :img => @img, :average_foil => @average_foil}
				end
			end
		end
	end
	
	def index
		
		if(params[:url].present?)
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/#{CGI.escape(params[:url])}"))
		else
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/?mainPage=showSearchResult&searchFor=#{CGI.escape (params[:query].gsub(/\//,' '))}&searchSingles=Y"))
		end
		
		result = MagicCardMarketScrapper.search(doc)
		
		@several = result["several"]
		@versions = result["versions"]
		@prices = result["prices"]
		@query = result["query"]
		@query = @query.gsub(/\//,' ') if @query
		@img = result["img"]
		
		
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
