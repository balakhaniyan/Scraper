require 'nokogiri'
require 'open-uri'
require 'json'
class Scraper
  attr_accessor :base_url, :city_names, :city_name, :web_page, :city_day_info, :web_page_data, :data_for_selection, :date, :current_main_url, :selecting_tree, :file
  # @author mohammad reza balakhaniyan
  # @version 1.2
  # describe : it sets initial values and variables: yahoo url and cities that we want information about
  def initialize
    @city_names = %w[Chicago Tokyo London Paris] # cities that we want to get daily weather information about
    @base_url = 'https://www.yahoo.com' # set the main website for connection
  end

  # @param url:string webpage url that we want open
  # describe: set the url that open_web_page func want to connect
  def set_url(url)
    @current_main_url = url
  end

  # open webpage url and set it as web_page global value for get info with read_web_page
  def open_web_page
    @web_page = open(@current_main_url)
    # we open the url by open-uri library: it's argument is web_page url
  end

  # get all html data from webpage and set @web_page_data for getting main data
  def read_web_page
    @web_page_data = Nokogiri::HTML(@web_page)
    # we select all link elements that their content is cityNames with css format: parent child element => .: it's class #:it's id nothing: it's tagName
  end

  # @param selecting_tree:string that set by user or other func that sets selecting_tree variable for selecting usable elements by set_data_for_selection func
  def set_selecting_tree(selecting_tree)
    @selecting_tree = selecting_tree
  end

  # get elements data and contents for run a get data from and realize attr values
  # this set data_for_selection by elements valuable data
  def set_data_for_selection
    @data_for_selection = @web_page_data.css(@selecting_tree)
  end

  # this function set today as date
  def set_date
    @date = Date.today # an object that show today date for inserting values in json file
  end

  # this function add one day to date (go to tomorrow!)
  def add_date
    @date = @date.next
  end

  # @param tag:string that initialize by tagName or id or className and we can get attr value from it
  # @param attr:string it is attr name like href that we find value of it
  # @return it returns special attr value from special tag
  # @example for example we find href value
  def get_attr(tag, attr)
    tag[attr]
    # we select the attr by ['attrName']
  end

  # @param uri:string the url that we want to encode
  # @return:string it returns encoded uri
  # URI.escape used to modify non-ASCII chars: this function encode non-ASCII chars
  def escape_uri(uri)
    URI.escape uri
  end

  # @return:string it return the content of special element that set by data_for_selection
  # 0: just first element have valuable data
  # other elements have extra data
  def get_content
    @data_for_selection[0].content
  end

  # this function get all data from every city url and add it to a hash variable
  # this do that by other funcs and call that for setting urls and opening and get html data and get elements and get attr values
  def get_data
    set_date # set today as date
    @city_day_info = {:city => @city_element.content} # we create a hash and put cityName => : is a symbol and we use it for inserting by it's value
    set_url(@base_url + escape_uri(get_attr(@city_element, 'href'))) # set base url +  href value as url and encode
    open_web_page # open url set before
    read_web_page # read all data of opened url
    set_selecting_tree('.accordion div.BdB') # set tree for select the element
    set_data_for_selection # select the elements that we want info about
    data_for_selection.each do |day_info| # run a loop on data and set day_info
      @web_page_data = day_info
      set_selecting_tree 'span img'
      set_data_for_selection
      forecast = get_attr(@data_for_selection[0], 'title')
      set_selecting_tree 'span span span'
      set_data_for_selection
      precipitation = get_content
      set_selecting_tree 'span .high'
      set_data_for_selection
      high = get_content.to_i
      # to_i extract all first numeric chars
      set_selecting_tree 'span .low'
      set_data_for_selection
      low = get_content.to_i
      # to_i extract all first numeric chars
      @city_day_info[date.to_s] = {:forecast => forecast, :precipitation => precipitation, :high => high, :low => low}
      # create a new hash and we put 4 variable in it:
      # points:
      # every selected element has extra information and we choice first element for ignore this data
      add_date
      # select next day (go to tomorrow!)
    end
  end

  # @param file_name:string that is a name that we want to create a file with this name
  # it sets @file value with file object
  def open_file(file_name)
    @file = File.open(file_name + '.json', 'w')
    #  we concat the name with .json for the fileName : w => it's writable
  end

  #  @city_day_info:string It is written in the file as json string
  # this function write a param value in file that set by @file
  def add_data_to_file
    @file.puts @city_day_info
    # puts : write the argument value in the file
  end

  # this func convert hash to
  def generate_day_info
    @city_day_info = JSON.pretty_generate @city_day_info
    # JSON.pretty_generate convert the hash to a standard and beautiful json string
  end

  # this function open a file with city_element.content name and convert hash to json string and write data to json file
  def save_data
    open_file @city_element.content
    generate_day_info
    add_data_to_file
  end

  # @param file_name:string name of file that we want to remove
  # this func remove the specific file
  def delete_file(file_name)
    File.delete(file_name + '.json')
  end

  # @param file_name:string string name of file that we want to check if exist or not?
  # this func check the specific file exists or not?
  def file_exist(file_name)
    File.exist?(file_name + '.json')
  end

  # this function remove all json file that is in this directory and with cityNames
  def remove_files
    @city_names.each do |cn| # for every city name that might a file exist
      delete_file cn if file_exist cn
      # remove file
    end
  end

  def main
    @data_for_selection.each do |city_name|
      @city_element = city_name
      if @city_names.include? @city_element.content # we put name of special cities in a word array and by this including statement we can figure out if we want this city url or not: content  => cityName
        # fourth we run a loop on all of them by a special name for selecting special cities
        get_data
        save_data
      end
    end
  end
end
