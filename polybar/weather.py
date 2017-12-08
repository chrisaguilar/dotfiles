#!/bin/python

import json
import time

from urllib.request import urlopen

def main():
    api_key = 'cb254703b9d67fbf04cae66e496e1aaa'
    lat = '33.60'
    lon = '-84.37'
    api_url = f'https://api.darksky.net/forecast/{api_key}/{lat},{lon}'

    try:
        weather = json.loads(urlopen(api_url).read())['currently']
        temperature = int(weather['temperature'])
        summary = weather['summary'].lower()
        print(f'{temperature}°F, {summary}')

    except:
        time.sleep(1)
        main()

main()
