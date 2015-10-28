#Squarestock
A stock tracker app made for Squarespace as part of the internship interview process.

###Idea:
Squarestock is a simple and clean app to keep up to date with the latest movements of any stock at any of the major market exchanges. 

###Design:
![Design Suggestion](design1.png)

When designing Squarestock, simplicity was an important factor. Many of the existing stock tracker apps (including the one built-into iOS) are overly cluttered and advanced. For most people this may be what they want, but for people like me I just want a simple overview of the daily movements of a given stock.

###Features:
Given the time restrictions and current workload, I didn't have time to implement many of the features I wanted to work on. Therefore, as of now, the app only allows you to search for a ticker given either part of the ticker or company name, see the latest stock price for that ticker, see what market it is trading on and whether it is open, and the daily movements*. 

###How to use:
Opening the app for the first time, you should see information about AAPL (Apple Inc.). If you want to change what ticker you're looking at, you can either tap the search button in the upper left corner or simply on the title of the ticker (AAPL). Start typing either the ticker symbol or company name, and press the row that matches what you want. To dismiss the search controller without selecting a new ticker, simply tap anywhere outside of the table and textfield (for example on either of the sides, or above the textfield).

###Architecture:
I used the Apple recommended MVC (Model-View-Controller) architecture, with the addition of *managers*. A manager is responsible for querying the web services, handling the response, and creating the objects.

---

###Development problems:
The biggest problem I faced was that there is no official documented unified API to get information about the stock market or individual stocks. The Google Finance API was shut down several years ago, and contrary to popular belief, Yahoo! Finance does not provide an official API. The only one I could find was Bloomberg, but it costs about $799 a year. 

As a result I had to use old undocumented unofficial APIs from Yahoo! Finance. The first one is a symbol lookup api, which given a string searches their database of stock exchanges for a company or ticker that matches your query. This API runs over plain HTTP, and as a result I had to manually specify that the app allows unsecure connections. 

The second is a stock data API from Yahoo! Finance (documented here: [http://www.jarloo.com/yahoo_finance/](http://www.jarloo.com/yahoo_finance/)), which returns data in CSV format. This is not ideal, but wasn't too hard to parse. The problem is that this only gives the current data (not historical) and the data isn't standardized: It returns the price in the local currency of the stock, without specifying what currency it is. Timestamps are given in "HH:mma" (10:30am) format as strings, but again in the local timezone of the stock without specifying what timezone it is. To work around this I had to concat the date and time strings returned from the API, and convert them into a NSDate object using the current local timezone. This is not ideal, but it's the best I can do with the data given.

As mentioned the Yahoo! Finance API does not give historical data, which is needed for the line chart. After a long night of Googling around for solutions, I decided to employ a temporary workaround for demonstration purposes. Instead of having accurate prices for every hour, I use the open and current price as endpoints and generate random values between to show off the chart. Since the data and times are random, I decided to redesign the chart a little bit: I removed the labels on the x and y axis, and disabled user interaction. Originally moving your finger over the chart would update the price and time label to reflect the price at that time, but this doesn't work well with dummy data. 

There is also no API to get information about a specific market. I wanted to use this to inform the user whether the market was open, closed, or data delayed. Instead I'm  now using the time of the given stock price to determine whether the market is open or closed: if the data is older than 1h, it's most likely closed. 

###Future fetures
* 3D Touch on Homescreen: Force touching on the app icon should bring up a list over the most recently viewed stocks and their current price. Tapping either of them should bring you right into the detail view for that ticker. 
* Notification center widget: See information about your currently selected stock right in the notification center.
* Live hourly data for the day displayed in the line chart, scrolling your finger over it should update the price and time label above. 
* Display local currency of the given stock.
* Display time for price update in current timezone.
* Show actual opening/closed/delayed information in the status label.