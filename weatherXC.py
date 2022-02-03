#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  2 23:47:28 2022

@author: mattyoung
"""
import json
import requests
import pandas as pd
from pandas.io.json import json_normalize

#Weather v Cross Country
df_list = []
city = ['Tallahasee','Stillwater','Terra Haute','Madison','Louisville']
zipcodes = ['32311', '74075', '47801','53593','40241']
dates = ['2021-11-20','2021-03-15','2019-11-23','2018-11-17','2017-11-18']
years = ['2021','2020','2019','2018','2017']

#Collect weather data on XC nationals and compare with previous week rankings
for x, y in zip(zipcodes,dates):
    weather_key = '7feb2c95e6fd45dfbc653851220302'
    BaseURL = 'http://api.worldweatheronline.com/premium/v1/past-weather.ashx'
    URLPost = {'key': weather_key,
           'q' : x,
           'date' : y,
           'format' : 'json'}
    r2= requests.get(BaseURL, URLPost) #pull information combining both BaseURL and URLPost
    out = json.loads(r2.text) #Load the data into json
    clean = json_normalize(out, record_path = ['data','weather'])#Normalize the data
    zipDF = pd.DataFrame(clean) #transform data to DF
    df_list.append(zipDF)

weather = pd.concat(df_list)

weather['Year'] = years
weather['zipCode'] = zipcodes
weather['city'] = city

weather = weather.drop(columns={'astronomy','hourly'})

weather.to_csv('weather_xc.csv', index=False)
