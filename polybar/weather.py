#!/bin/python

import time
import urllib.request, json

def main():
    try:
        city = "30297"
        api_key = "ba345b9219e4508665da076f3599e816"
        units = "Imperial"
        unit_key = "F"

        weather = eval(
            str(
                urllib.request.urlopen(
                    "http://api.openweathermap.org/data/2.5/weather?q={}&APPID={}&units={}".
                    format(city, api_key, units)).read())[2:-1])

        info = weather["weather"][0]["description"].capitalize()
        temp = int(float(weather["main"]["temp"]))

        # print("%s, %i°%s" % (info, temp, unit_key))
        print("%i°%s" % (temp, unit_key))
    except:
        time.sleep(1)
        main()

main()
