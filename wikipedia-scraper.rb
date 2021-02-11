require "open-uri"
require "nokogiri"
require "csv"

def scrape_restaurants(webpage, element)
  # Define Webpage and HTML content.
  url = webpage
  html_content = open(url).read
  doc = Nokogiri::HTML(html_content)
  hash_of_restaurants = {}
  # Loop through "elements"
  doc.search(element).each do |element|
    name = element.css('.spot-block__title-block h3').text.strip
    array_of_title_element = []
    element.css('.spot-block__title-block .overview-content .overview-bold').each do |title_element|
      array_of_title_element << title_element.text.strip
    end
    array_of_description_element = []
    element.css('.spot-block__description-section').each do |description_element|
      array_of_description_element << description_element.css('p').text.strip
      # IF link is not provided, mark down as "No Link"
      array_of_description_element << (description_element.css('a').attribute('href').nil? ? "No link" : description_element.css('a').attribute('href').value)
    end
    hash_unique = {name => { cuisine: array_of_title_element[0], location: array_of_title_element[1], description: array_of_description_element[0], link: array_of_description_element[1]}}
    #Merge results into large object
    hash_of_restaurants.merge!(hash_unique)
  end
  return hash_of_restaurants
end

#Move to excel friendly format
headers = ['Name','Cuisine','Location','Description','Link']
CSV.open("restaurant_list_v3.csv", "w") do |csv|
  #Excel Friendly symbols only
  csv.to_io.write "\uFEFF"
  csv << headers
  result = scrape_restaurants('https://www.theinfatuation.com/london/guides/london-restaurants-with-new-delivery-collection-options', '.spot-block')
  csv_data = []
  i = 0
  result.each do |k,v|
   csv_data << k
   csv_data << v[:cuisine]
   csv_data << v[:location]
   csv_data << v[:description]
   csv_data << v[:link]
   csv << csv_data
   csv_data = []
  end
 end

 def count_links(webpage, element)
  result = scrape_restaurants(webpage, element)
  
  bignight = []
  dishpatch = []
  restokit = []
  result.each do |k,v|
    case
    when v[:link].index('bignight').nil? == false
      bignight << k
    when v[:link].index('dishpatch').nil? == false
      dishpatch << k
    when v[:link].index('restokit').nil? == false
      restokit << k 
    end 
  end
  p bignight
  p dishpatch
  p restokit
 end

 count_links('https://www.theinfatuation.com/london/guides/london-restaurants-with-new-delivery-collection-options', '.spot-block')