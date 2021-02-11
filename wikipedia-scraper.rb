require "open-uri"
require "nokogiri"
require "csv"

def scrape_wikipedia(webpage, element)
  # Define Webpage and HTML content.
  url = webpage
  html_content = open(url).read
  doc = Nokogiri::HTML(html_content)
  results = {}
  # Loop through "elements"
  doc.search(element).each do |element|
    if element.text.strip.match?(/(?<centre_name>(\w+\s?)+), (?<location>(\w+\s?)+)/)
      match_data = element.text.strip.match(/(?<centre_name>(\w+\s?)+), (?<location>(\w+\s?)+)/)
      name = match_data[:centre_name]
      location = match_data[:location]
    end
    array_of_links = []
    element.css('a').each do |link|
      array_of_links << "https://en.wikipedia.org#{link.attribute('href').value}"
    end
    hash_unique = {name => { location: location, link: array_of_links[0]}}
    results.merge!(hash_unique)  
  end
    results.each do |k,v|
    sub_url = v[:link]
    begin 
      html_content = open(sub_url).read
      doc = Nokogiri::HTML(html_content)
    rescue OpenURI::HTTPError => e
      puts "Can't access #{ sub_url }"
      puts e.message
      puts
      next
    end
    # Loop through "elements"
    doc.search('.infobox').each do |sub_element|
      geo_location = sub_element.css('.geo-dec').text.strip
      results[k].merge!(geo_location: geo_location)
      sub_element.css('tr').each do |table_row|
      # Find Owner  
        if table_row.css('th').text.strip == "Owner"
          owner = table_row.css('td').text.strip
          results[k].merge!(owner: owner)
        end #end of owner
      #Find total retail area 
        if table_row.css('th').text.strip == "Total retail floor area"
          nia = table_row.css('td').text.strip
         results[k].merge!(nia: nia)
        end #end of retail area

      #Parking 
      if table_row.css('th').text.strip == "Parking"
        parking = table_row.css('td').text.strip
       results[k].merge!(parking: parking)
      end #end of parking
      
      end #end of table row
      
      p results[k]
    end #end of sub_element
  
  end #end of hash
  p results
end

scrape_wikipedia("https://en.wikipedia.org/wiki/List_of_shopping_centres_in_the_United_Kingdom", ".mw-parser-output ul li")

def scrape_sub_wikipedia(webpage, element)
  # Define Webpage and HTML content.
  url = webpage
  html_content = open(url).read
  doc = Nokogiri::HTML(html_content)
  results = {}
  # Loop through "elements"
  results = {}
  doc.search(element).each do |element|
    geo_location = element.css('.geo-dec').text.strip
    element.css('tr').each do |table_row|
    # Find Owner  
      if table_row.css('th').text.strip == "Owner"
        owner = table_row.css('td').text.strip
      end
    #Find total retail area 
      if table_row.css('th').text.strip == "Total retail floor area"
        nia = table_row.css('td').text.strip
      end

    #Parking 
    if table_row.css('th').text.strip == "Parking"
      parking = table_row.css('td').text.strip
    end
    hash_unique = {"hammerson" => { geo_location: geo_location, owner: owner, nia: nia, parking: parking }}
    results.merge!(hash_unique) 
    end

    p results
  end 
end

# scrape_sub_wikipedia("https://en.wikipedia.org/wiki/Brent_Cross_Shopping_Centre", ".infobox" )







#Move to excel friendly format
# headers = ['Name','Cuisine','Location','Description','Link']
# CSV.open("restaurant_list_v3.csv", "w") do |csv|
#   #Excel Friendly symbols only
#   csv.to_io.write "\uFEFF"
#   csv << headers
#   result = scrape_restaurants('https://www.theinfatuation.com/london/guides/london-restaurants-with-new-delivery-collection-options', '.spot-block')
#   csv_data = []
#   i = 0
#   result.each do |k,v|
#    csv_data << k
#    csv_data << v[:cuisine]
#    csv_data << v[:location]
#    csv_data << v[:description]
#    csv_data << v[:link]
#    csv << csv_data
#    csv_data = []
#   end
#  end
