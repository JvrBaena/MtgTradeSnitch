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
			@average =@average/result["prices"].size
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
		end
	end
	
	def index
		
		if(params[:url].present?)
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/#{CGI.escape(params[:url])}"))
		else
			doc = Nokogiri::HTML(open("http://www.magiccardmarket.eu/?mainPage=showSearchResult&searchFor=#{CGI.escape (params[:query])}&searchSingles=Y"))
		end
		
		result = MagicCardMarketScrapper.search(doc)
		
		@several = result["several"]
		@versions = result["versions"]
		@prices = result["prices"]
		@query = result["query"]
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
