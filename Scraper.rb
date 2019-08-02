require 'nokogiri'
require 'open-uri'
require 'json'
base_url = 'https://www.yahoo.com' # set the main website for connection
city_names = %w[Chicago Tokyo London Paris] # cities that we want to get daily weather information about
def get_data(base_url, city_name, city_names)
  if city_names.include? city_name.content # we put name of special cities in a word array and by this including statement we can figure out if we want this city url or not: content  => cityName
    date = Date.today # an object that show today date for inserting values in json file
    city_day_info = {:city => city_name.content} # we create a hash and put cityName => : is a symbol and we use it for inserting by it's value
    Nokogiri::HTML(open(base_url + URI.escape(city_name['href']))).css('.accordion div.BdB').each do |day|
      # it's is exactly like the previous step and has 4 steps
      # differences:
      # the url contains 2 part: 1.base url => constant 2.links that we get from cityName's href attr
      # URI.escape used to modify non-ASCII chars: this function encode non-ASCII chars
      city_day_info[date.to_s] = {:forecast => day.css('span img')[0]['title'], :precipitation => day.css('span span span')[0].content, :high => day.css('span .high')[0].content.to_i, :low => day.css('span .low')[0].content.to_i}
      # create a new hash and we put 4 variable in it:
      # points:
      # every selected element has extra information and we choice first element for ignore this data
      # we select the attr by ['attrName']
      # to_i extract all first numeric chars
      date = date.next # select next day (go to tomorrow!)
    end
    File.open(city_name.content + '.json', 'w').puts JSON.pretty_generate city_day_info
    # it has 4 step:
    # first: we get city_name for saving by city_name.content
    # second we concat the name with .json for the fileName : w => it's writable
    # third: JSON.pretty_generate convert the hash to a standard and beautiful json string 
    # forth: puts : write the argument value in the file
  end
end

# every word in an element of word array
Nokogiri::HTML(open('https://yahoo.com/news/weather')).css('#app div div .sticky-outer-wrapper .sticky-inner-wrapper div div div #mrt-node-Side-2-WeatherStaticList #Side-2-WeatherStaticList-Proxy .weather-card ul li a').each do |city_name|
  # 4 level:
  # first we open the url by open-uri library: it's argument is web_page url
  # second we send the return value of the previous function to nokogiri::html because we want to connect to that web_page
  # third we select all link elements that their content is cityNames with css format: parent child element => .: it's class #:it's id nothing: it's tagName
  # forth we run a loop on all of them by a special name for selecting special cities
  get_data(base_url, city_name, city_names)
end