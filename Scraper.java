import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class Scraper {
    public static void main(String[] args) throws IOException, ParseException {
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        /*
           in this line we define a formatter to set date in a standard format to saving data in json file by date key
           we create a new instance of SimpleDateFormat class by pattern as argument
           we used java.text.SimpleDateFormat library
         */
        Document document = Jsoup.connect("https://www.yahoo.com/news/weather").get();
        /*
        in this line, we connect to web_page by special url and get all of content as a Document object
        it can show as an string for user
         */
        Elements cities_list = document.body().select("#app div div .sticky-outer-wrapper .sticky-inner-wrapper div div div #mrt-node-Side-2-WeatherStaticList #Side-2-WeatherStaticList-Proxy .weather-card ul li a");
        /*
        we call body element of html doc and select all link elements that have names and links of all cities show in webPage
        we select all elements by css syntax, like this: parent child
        and we have this rule: #: id .: class nothing: tagName
         */
        String[] required_cities = {"Chicago", "Tokyo", "London", "Paris"};
        /*
        we have an array of all major cities that we want daily weather info about
        this array contains of cities and are major cities of yahoo website
         */
        for (Element city_list : cities_list)
            // a foreach loop run on all links elements
            if (Arrays.asList(required_cities).contains(city_list.text())) {
                /*
                there is an function in Array library that convert Array to List for search and etc
                by contain function we check if the list has the text of element (cityName)?
                if true, then do other commands
                else di nothing
                 */
                Date date = new Date(System.currentTimeMillis());
                /*
                create an Date instance by current time value ti create an object that has time of now in milliSecond
                because we want to save data in json file by date as key
                 */
                String formatted_date = formatter.format(date);
                /*
                above function give us date as an object and milliSec, for change it in standard format and saving:
                we format it by formatter object that created before
                 */
                HashMap<String, Object> city_info_hash = new HashMap<>();
                /*
                we create a hash for save details to save that in end to json file
                the key is in string format
                but the value is in Object:
                because the type of value is variable: string or hash
                 */
                city_info_hash.put("city", city_list.text());
                // we save city name in hash by city key and name value
                Document city_info = Jsoup.connect(URI.create(city_list.absUrl("href")).toASCIIString()).get();
                /*
                we get href attr as an url value and connect by jsoup.connect
                URI.create and toASCIIString()) used to modify non-ASCII chars: this function encode non-ASCII chars
                 */
                Elements days_list = (city_info.select(".accordion div.BdB"));
                /*
                select daily info divs for extract details
                it is in css format too
                 */
                FileOutputStream print = new FileOutputStream(city_list.text() + ".json");
                /*
                 we create a FileOutputStream by this name: city name + .json
                 that manage the json file
                 the city_list.text() contains name of city
                */
                print.write(setData(getDailyInfo(days_list, formatted_date, city_info_hash), 2).getBytes());
                /*
                first we send hash and element list to getDailyInfo to get all of details as hash
                then we send it's return value to setData function to convert it to json string value with pretty format
                then we convert it to Bytes, so we can put it in FileOutputStream
                that put all of data in a json file by city name
                 */
                print.close();
            }
    }
    /*
    getDailyInfo function:
    3 params:
    1.days_list(Elements): has all days elements as a list for extracting data from it
    2.formatted_date(String): current date for saving data
    3.city_info_hash(HashMap<String, Object>): a hash by city_name for saving 10 days details
    return vale:
    a hash that contains all of daily data
     */
    private static HashMap getDailyInfo(Elements days_list, String formatted_date, HashMap<String, Object> city_info_hash) throws ParseException {
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        /*
           in this line we define a formatter to set date in a standard format to saving data in json file by date key
           we create a new instance of SimpleDateFormat class by pattern as argument
           we used java.text.SimpleDateFormat library
         */
        Calendar calendar = Calendar.getInstance();
        // we create a calendar instance for set date: every step we add one day to date
        for (Element day_info : days_list) {
            // for every element of daily list
            String forecast = day_info.select("span img").attr("title");
            /*
            we select image  by css format and
            attr by attr function because it contains forecast value
             */
            String precipitation = day_info.select("span span span").text();
            // we select precipitation by 3 span and text of 3rd span is precipitation value
            /*
            in next 6 lines:
            we select high and low temp element by css format and get text of them
            if length is bigger than 1 then ignore last char and convert it to integer
             */
            String high_temp_str = (day_info.select("span .high").text());
            if (high_temp_str.length() >= 1)
                high_temp_str = high_temp_str.substring(0, high_temp_str.length() - 1);
            String low_temp_str = (day_info.select("span .low").text());
            if (low_temp_str.length() >= 1)
                low_temp_str = low_temp_str.substring(0, low_temp_str.length() - 1);
            HashMap<String, String> day_info_hash = new HashMap<>();
            // we create a hash for daily info
            day_info_hash.put("forecast", forecast);
            day_info_hash.put("precipitation", precipitation);
            day_info_hash.put("high", high_temp_str);
            day_info_hash.put("low", low_temp_str);
            // we put info in hash by key-val format
            city_info_hash.put(formatted_date, day_info_hash);
            // then we put it in major hash by current date as key and hash as value
            calendar.setTime(formatter.parse(formatted_date));
            /*
            convert date to an date object
            then set is as calendar time
             */
            calendar.add(Calendar.DATE, 1);
            // add one day to it
            formatted_date = formatter.format(calendar.getTime());
            // then convert it to a string
        }
        return city_info_hash; // return new hash
    }
    /*
    3 recursion function with same name: setData
    it convert the json hash to a json string
    params:
    hash - arrayList - String: for putting it in parent hash or arrayList
    indent: a number that shows how may space put first of line for beautify
    return value: a string that contains info
     */
    private static String setData(HashMap value, int indent) {
        StringBuilder json = new StringBuilder("{");
        // first we build a string by one char: {
        int i = 0;
        // an int variable for doesn't add , at end of hash or list element
        Set vk = value.keySet();
        // get all of keys of hashMap to add it in json string
        for (var object : vk) {
            // all elements are object because we don't know type of it
            json.append("\n").append(" ".repeat(2 * (indent - 1))).append("\"").append(object).append("\": ");
            /*
            we put a new line to json string then put appropriate spaces to it
            then put " because it is string
            number 2: every Nested block has 2 extra spaces
            indent: show level of block
             */
            if (value.get(object) instanceof HashMap)
                json.append(setData((HashMap) value.get(object), indent + 1));
            // if value is hash send it to appropriate function(this func)
            else if (value.get(object) instanceof ArrayList)
                json.append(setData((ArrayList) value.get(object), indent + 1));
            // else send it to appropriate function
            else
                json.append(setData((String) value.get(object)));
            // else add it as an string or number to json string by this func
            if (i != vk.size() - 1)
                json.append(",");
            // if it is not last element add , at end of it
            i++;
        }
        if (!value.isEmpty()) {
            json.append("\n");
            // if it's not empty add a blank line because of  standard json format
        }
        return json + (((!value.isEmpty()) ? " ".repeat(2 * (indent - 2)) : "") + "}");
        // if it was empty return an blank string else return value by indents
    }

    private static String setData(ArrayList value, int indent) {
        StringBuilder json = new StringBuilder("[");
        for (var object : value) {
            json.append("\n").append(" ".repeat(2 * (indent - 1)));
            if (object instanceof HashMap)
                json.append(setData((HashMap) object, indent + 1));
            else if (object instanceof ArrayList)
                json.append(setData((ArrayList) object, indent + 1));
            else
                json.append(setData((String) object));
            if (value.indexOf(object) != value.size() - 1)
                json.append(",");
        }
        if (!value.isEmpty())
            json.append("\n");
        return json + (((!value.isEmpty()) ? " ".repeat(2 * (indent - 2)) : "") + "]");
    }

    private static String setData(String value) {
        if (value.matches("[-+]?[1-9]\\d*\\.?\\d+"))
            return value;
        // an regex that check if it is number add it as number
        return "\"" + value + "\"";
        // add it to json string as an string
    }
}