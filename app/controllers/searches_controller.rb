require 'open-uri'
class SearchesController < ApplicationController
	def average
	  if(params[:url].present?)
	    card = Card.find_by_url(params[:url])
    else
      card= Card.find_by_card(params[:id])
    end
    if card
      mins = (Time.now - card.updated_at)/60
      valid = mins < 10
      @img = card.pic.url
      @query = card.card
    end
    if card && valid
      @average = card.average_nonfoil
      @average_foil = card.average_foil
    else
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
        if !@img.present?
  			  @img = result["img"]
			  end
			  
  			@average = result["prices"].inject(0.0) do |res,element|
          comments_string = element["comments"]
          comments_string = comments_string.downcase.gsub(/\W+/,"").strip  
          if(comments_string.include?("playset"))
            element["foil"].nil? ? res + (element["price"].gsub("\u20AC","").gsub(",",".").to_f)/4 : res + 0
          else
            element["foil"].nil? ? res + element["price"].gsub("\u20AC","").gsub(",",".").to_f : res + 0
          end
  			end
  			@average_foil = result["prices"].inject(0.0) do |res,element|
  			  comments_string = element["comments"]
          comments_string = comments_string.downcase.gsub(/\W+/,"").strip 
  			  if(comments_string.include?("playset"))
  			    element["foil"].present? ? res + (element["price"].gsub("\u20AC","").gsub(",",".").to_f)/4 : res + 0
			    else
			      element["foil"].present? ? res + element["price"].gsub("\u20AC","").gsub(",",".").to_f : res + 0
		      end
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
  		if params[:url].present?
  		  card = Card.find_or_create_by_url(params[:url])
  		  if !card.pic_file_name.present?
  		    card.picture_from_url(@img)
		    end
  		  card.update_attributes(:card => nil, :url => params[:url], :average_foil => @average_foil, :average_nonfoil => @average )
  		  @img = card.pic.url
  		elsif !@several.present?
  		  card = Card.find_or_create_by_card(:card => params[:id])
  		  if !card.pic_file_name.present?
  		    card.picture_from_url(@img)
		    end
  		  card.update_attributes(:card => params[:id], :url => nil, :average_foil => @average_foil, :average_nonfoil => @average)
  		  @img = card.pic.url
  	  end
    	
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
					render :xml => {:average => @average , :img => card.pic.url, :average_foil => @average_foil}
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
