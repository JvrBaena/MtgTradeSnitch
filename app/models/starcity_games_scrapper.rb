require 'anemone'
require 'open-uri'


 def test4
	 root = Nokogiri::HTML(open("http://sales.starcitygames.com/singlecategories.php"))
	 ediciones = root.css('td td div[align="center"]>a').collect{|e| e.attribute("href").value}
	 fichero = File.open("cartas.txt", "w") do |file|
		 hilos = []
		 5.times do #5 tentáculos a ver si lo aguanta starcitygames
			 hilos << Thread.new{
				while ediciones.any?
					tentaculo ediciones.pop, file
				end
			 }
			 
		 end
		 
		 hilos.each do |t|
			t.join
		 end
	end
	fichero.close
 end
 
def tentaculo(url , output) 
	doc = Nokogiri::HTML(open(url))
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
			
			output.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
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
				
				output.puts "Carta: "+title.content+"\t"+"Precio: "+price.content+"\t"+"Expansion: "+exp.content+"\t"+"condition"+condition.content
				
			end
		end
		
		sig = page.xpath('//a[contains(.,"Next")]').first()
	end
end
 
test4

#category.php\?(t=a)?&cat=\d+(&letter=.|&start=\d+)?     td td div a
