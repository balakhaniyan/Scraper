require 'rspec'
require '../TestableScraper'
RSpec.describe Scraper do
  it 'we want to get base_url' do
    scraper = Scraper.new
    expect(scraper.base_url).to eql('https://www.yahoo.com')
  end
  it 'we want to know cities' do
    scraper = Scraper.new
    expect(scraper.city_names).to eql(%w[Chicago Tokyo London Paris])
  end
  it 'set webpage url' do
    scraper = Scraper.new
    scraper.set_url 'https://www.yahoo.com/news/weather'
    expect(scraper.current_main_url).to eql('https://www.yahoo.com/news/weather')
  end
  it 'open web_page' do
    scraper = Scraper.new
    scraper.set_url 'https://www.yahoo.com/news/weather'
    res = scraper.open_web_page
    expect(res.base_uri.to_s).to eql('https://www.yahoo.com/news/weather')
  end
  it 'read web_page' do
    scraper = Scraper.new
    scraper.set_url 'https://www.yahoo.com/news/weather'
    scraper.open_web_page
    res = scraper.read_web_page
    expect(res.css('div').count).to eql(197)
  end
  it 'select city elements' do
    scraper = Scraper.new
    scraper.set_url 'https://www.yahoo.com/news/weather'
    scraper.open_web_page
    scraper.read_web_page
    scraper.set_selecting_tree('#app div div .sticky-outer-wrapper .sticky-inner-wrapper div div div #mrt-node-Side-2-WeatherStaticList #Side-2-WeatherStaticList-Proxy .weather-card ul li a')
    scraper.set_data_for_selection
    expect(scraper.data_for_selection.count).to eql(12)
  end
  it 'set date' do
    scraper = Scraper.new
    expect(scraper.set_date.to_s).to eql('2019-08-05')
    expect(scraper.set_date.to_s).to eql(Date.today.to_s)
  end
  it 'add date' do
    scraper = Scraper.new
    scraper.set_date.to_s
    expect(scraper.add_date.to_s).to eql('2019-08-06')
    expect(scraper.add_date.to_s).to eql(Date.today.next.next.to_s)
  end
  it 'get tag attr value' do
    scraper = Scraper.new
    scraper.set_url 'https://www.yahoo.com/news/weather'
    scraper.open_web_page
    scraper.read_web_page
    scraper.set_selecting_tree('#app div div .sticky-outer-wrapper .sticky-inner-wrapper div div div #mrt-node-Side-2-WeatherStaticList #Side-2-WeatherStaticList-Proxy .weather-card ul li a')
    res = scraper.get_attr(scraper.set_data_for_selection[0], 'href')
    expect(res).to include('/news/weather/united-states/new-york/new-york')
  end
  it 'escape uri' do
    scraper = Scraper.new
    scraper.set_url 'https://www.yahoo.com/news/weather'
    scraper.open_web_page
    scraper.read_web_page
    scraper.set_selecting_tree('#app div div .sticky-outer-wrapper .sticky-inner-wrapper div div div #mrt-node-Side-2-WeatherStaticList #Side-2-WeatherStaticList-Proxy .weather-card ul li a')
    res = scraper.escape_uri(scraper.get_attr(scraper.set_data_for_selection[10], 'href'))
    expect(res).to include('/news/weather/france/%C3%AEle-de-france/paris')
  end
  it 'get content' do
    scraper = Scraper.new
    scraper.set_url 'https://www.yahoo.com/news/weather'
    scraper.open_web_page
    scraper.read_web_page
    scraper.set_selecting_tree('#app div div .sticky-outer-wrapper .sticky-inner-wrapper div div div #mrt-node-Side-2-WeatherStaticList #Side-2-WeatherStaticList-Proxy .weather-card ul li a')
    scraper.set_data_for_selection
    expect(scraper.get_content).to eql('New York')
  end
  it 'open file' do
    scraper = Scraper.new
    file = scraper.open_file('cityName')
    expect(file.class.to_s).to include('File')
  end
  it 'generate json string' do
    scraper = Scraper.new
    scraper.city_day_info = {:city => 'Chicago'}
    scraper.city_day_info['2019-8-5'] = {:forecast => 'Fair', :high => 12}
    expect(scraper.generate_day_info).to eql("{\n  \"city\": \"Chicago\",\n  \"2019-8-5\": {\n    \"forecast\": \"Fair\",\n    \"high\": 12\n  }\n}")
  end
  it 'add data to file' do
    scraper = Scraper.new
    scraper.city_day_info = {:city => 'Chicago'}
    scraper.city_day_info['2019-8-5'] = {:forecast => 'Fair', :high => 12}
    scraper.open_file 'city_info'
    scraper.generate_day_info
    scraper.add_data_to_file
    expect(File.open(scraper.file).read).to eql("{\n  \"city\": \"Chicago\",\n  \"2019-8-5\": {\n    \"forecast\": \"Fair\",\n    \"high\": 12\n  }\n}")

  end
  it 'exist file' do
    scraper = Scraper.new
    expect(scraper.file_exist('city_info')).to eql(true)
    expect(scraper.file_exist('city_info0')).to eql(false)
  end
  it 'remove file' do
    scraper = Scraper.new
    expect(scraper.delete_file('city_info')).to eql(1)
  end
  it 'test all' do
    s = Scraper.new
    s.set_url 'https://www.yahoo.com/news/weather'
    s.open_web_page
    s.read_web_page
    s.set_selecting_tree('#app div div .sticky-outer-wrapper .sticky-inner-wrapper div div div #mrt-node-Side-2-WeatherStaticList #Side-2-WeatherStaticList-Proxy .weather-card ul li a')
    s.set_data_for_selection
    s.main
    expect(s.file_exist('Chicago.json')).to eql(true)
    expect(s.file_exist('London.json')).to eql(true)
    expect(s.file_exist('Paris.json')).to eql(true)
    expect(s.file_exist('Tokyo.json')).to eql(true)
  end
end