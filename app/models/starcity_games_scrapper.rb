require 'anemone'
require 'open-uri'
def test
	File.open("cartas.txt", "a") do |file|
		Anemone.crawl("http://sales.starcitygames.com/carddisplay.php?product=227809",{:threads => 10, :depth_limit => 2,:verbose => true}) do |anemone|
			anemone.skip_links_like(/search.php/,/contactus/,/cardconditions/,/category.php\?t=a/)
			anemone.on_pages_like(/carddisplay.php\?product=\d+/) do |page|
				doc = page.doc
				
				title = doc.at_css('.titletext')
				puts title.content
				price = doc.at_css('span.articletext b')
				puts price.content
				exp = doc.at_css('span + br + a')
				puts exp.content
				condition = doc.at_css('a[href="http://sales.starcitygames.com//cardconditions.php"]')
				puts condition.content
				
				file.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
			end
		end
	end
end

def test2
	File.open("cartas.txt", "a") do |file|
		(2553..56448).each do |n|
			doc = Nokogiri::HTML(open("http://sales.starcitygames.com/carddisplay.php?product=#{n}"))
			puts n
			if !doc.content.include?("That is either a non-valid product number, or an item that we have removed from stock.")
				title = doc.at_css('.titletext')
				puts title.content
				price = doc.at_css('span.articletext b')
				puts price.content
				exp = doc.at_css('span + br + a')
				puts exp.content
				condition = doc.at_css('a[href="http://sales.starcitygames.com//cardconditions.php"]')
				puts condition.content
				
				file.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
			end
		end
	end
	
end

def test3
	ts=[]
	(1..10).each do |i|
		x =Thread.new{
			starting = (i-1)*5389 +1 
			starting+=2552 if i==1
			ending = i * 5389
			
			File.open("cartas.txt", "a") do |file|
				(starting..ending).each do |n|
					doc = Nokogiri::HTML(open("http://sales.starcitygames.com/carddisplay.php?product=#{n}"))
					puts n
					if !doc.content.include?("That is either a non-valid product number, or an item that we have removed from stock.")
						title = doc.at_css('.titletext')
						puts title.content
						price = doc.at_css('span.articletext b')
						puts price.content
						exp = doc.at_css('span + br + a')
						puts exp.content
						condition = doc.at_css('a[href="http://sales.starcitygames.com//cardconditions.php"]')
						puts condition.content
						
						file.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
					end
				end
			end
			
		}
		ts << x
		
		x = Thread.new{
			File.open("cartas.txt", "a") do |file|
				(53890..53895).each do |n|
					doc = Nokogiri::HTML(open("http://sales.starcitygames.com/carddisplay.php?product=#{n}"))
					puts n
					if !doc.content.include?("That is either a non-valid product number, or an item that we have removed from stock.")
						title = doc.at_css('.titletext')
						puts title.content
						price = doc.at_css('span.articletext b')
						puts price.content
						exp = doc.at_css('span + br + a')
						puts exp.content
						condition = doc.at_css('a[href="http://sales.starcitygames.com//cardconditions.php"]')
						puts condition.content
						
						file.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
					end
				end
			end
		}
	end
	
	ts.each do |t|
		t.join
	end
end



 def test4
	 root = Nokogiri::HTML(open("http://sales.starcitygames.com/singlecategories.php"))
	 ediciones = root.css('td td div[align="center"]>a').collect{|e| e.attribute("href").value}
	 fichero = File.open("cartas.txt", "w") do |file|
		 hilos = []
		 ediciones.each do |e|
			 hilos << Thread.new{
				doc = Nokogiri::HTML(open(e))
				#Primera iteración es fuera del bucle
				links_first = doc.css('a.card_popup')
				if !links_first.nil?
					#Para cada enlace de carta
					links_first.each do |f|
						#Nos traemos esa carta y sacamos los datos de la presentación (esta es carddisplay)
						carta =  Nokogiri::HTML(open(f.attribute("href").value()))
						title = carta.at_css('.titletext')
						puts title.content
						price = carta.at_css('span.articletext b')
						puts price.content
						exp = carta.at_css('span + br + a')
						puts exp.content
						condition = carta.at_css('a[href="http://sales.starcitygames.com//cardconditions.php"]')
						puts condition.content
						
						file.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
					end
				end
				
				
				#Para el resto navegamos por el Next
				sig=doc.xpath('//a[contains(.,"Next")]').first()
				while sig do
					page = Nokogiri::HTML(open(sig.attribute("href").value()))
					
					links = page.css('a.card_popup')
					if !links.nil?
						#Para cada enlace de carta
						links.each do |f|
							#Nos traemos esa carta y sacamos los datos de la presentación (esta es carddisplay)
							carta =  Nokogiri::HTML(open(f.attribute("href").value()))
							title = carta.at_css('.titletext')
							puts title.content
							price = carta.at_css('span.articletext b')
							puts price.content
							exp = carta.at_css('span + br + a')
							puts exp.content
							condition = carta.at_css('a[href="http://sales.starcitygames.com//cardconditions.php"]')
							puts condition.content
							
							file.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
							
						end
					end
					
					sig = page.xpath('//a[contains(.,"Next")]').first()
				end
				
			 }
			 
		 end
		 
		 hilos.each do |t|
			t.join
		 end
	end
	fichero.close
 end
 
test4

#category.php\?(t=a)?&cat=\d+(&letter=.|&start=\d+)?     td td div a
