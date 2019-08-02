from bs4 import BeautifulSoup
import urllib.request
from urllib.parse import quote
import datetime
import json

forecast = BeautifulSoup(
    urllib.request.urlopen('https://www.yahoo.com/news/weather'), 'html.parser')
# open url address as a yahoo webPage
# it belongs to urllib for request
# and we connect to url by bs4 library with 2 argument: 1.webPage url 2.parser type: html
cities = forecast.find_all('ul', attrs={'class', 'Tsh($temperature-text-shadow)'})[0].find_all('li')
# select all list element in a special class that have cities names and urls
# first element that has the special class is major class
for city in cities:
    # for every city we get the inside link content
    city_link = city.find('a')  # we find first link element
    if city_link.text in ['Chicago', 'Tokyo', 'London', 'Paris']:  # if it's text (city name) is in requested cities:
        info_dict = {'city': city_link.text}
        # create a new dict and put city name in it
        date = datetime.datetime.today().date()
        # set date as today date by datetime library for saving data in json day by day
        city_forecast_info = BeautifulSoup(
            urllib.request.urlopen('https://www.yahoo.com' + quote(city_link['href'])), 'html.parser')
        # it is exactly like previous step and we open url and pass it to bs function
        # differences:
        # 1.quote used to modify non-ASCII chars: this function encode non-ASCII chars
        # 2. the url contains 2 part: 1.base url => constant 2.links that we get from cityName's href attr
        for daily_info in (city_forecast_info.find_all('div', attrs={'class':
                                                                         'BdB Bds(d) Bdbc(#fff.12) Fz(1.2em) Py(2px) O(0) Pos(r) forecast-item'})):
            # for every element (div) that has major special class names we run a loop and extract data
            # that divs have daily info and contains spans with details:
            # about forecast and precipitation and low and high temp
            daily_info_spans = daily_info.find_all('span')
            # we select all spans of the main div because that span contains special info
            day_dict = {'forecast': daily_info_spans[1].find('img')['alt'],
                        'precipitation': daily_info_spans[2].find('span').find('span').text,
                        'high': int(daily_info_spans[5].find('span', attrs={'class': 'high'}).text[:-1]),
                        'low': int(daily_info_spans[5].find('span', attrs={'class': 'low'}).text[:-1])}
            # create a new dict with data:
            # forecast: second span has an image with an alter to show weather
            # precipitation: third span has nested spans that nested span has a text for showing precipitation
            # high and low: 6th element has 2 span with 2 special class that contains info:
            # we extract them and ignore end char and convert to int
            info_dict[str(date)] = day_dict
            # add the pre dict to main dict by date key and dict as value
            date = date + datetime.timedelta(days=1)
            # select next day (go to tomorrow!)
        city_json = json.dumps(info_dict)
        # convert hash to json string
        open(city_link.text + '.json', 'w+').write(city_json)
        # first: we get city_name for saving by city_link.text
        # second we concat the name with .json for the fileName : w+ => it's writable
        # third: write : write the argument value in the file
