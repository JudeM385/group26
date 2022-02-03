#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  2 16:20:33 2022

@author: mattyoung
"""

url = 'https://www.ustfccca.org/team-rankings-polls-central/polls-rankings-hub?coll=1'

import urllib
from urllib.request import urlopen
import pandas as pd
from bs4 import BeautifulSoup
import requests

def make_soup(url):
    req = urllib.request.Request(url, headers={'User-Agent':'Mozilla/5.0'})
    webpage = urlopen(req)
    main_doc = webpage.read()
    return main_doc

df_collection=[]
soup = make_soup(url)
df_collection.append(pd.read_html(soup))

df = df_collection[0]
df = df[0]

##### Method 2 for other elements
req = requests.get(url)
content=req.text
soup2 = BeautifulSoup(content)
year = soup2.h4.text
detail = year[5:]
year = year[0:4]
season_gender = soup2.find_all("h5")[0].text
if 'Cross' in season_gender:
    season = 'Cross Country'
elif 'Outdoor' in season_gender:
    season = 'Outdoor Track'
else:
    season = 'Indoor Track'
if 'III' in season_gender:
    division = 'III'
elif 'II' in season_gender:
    division = 'II'
elif 'NJCAA' in season_gender:
    division = 'NJCAA'
elif 'NAIA' in season_gender:
    division = 'NAIA'
else:
    division = 'I'
if 'Women' in season_gender:
    gender = 'Women'
else:
    gender = 'Men'
df['Year'] = year
df['Season'] = season
df['Gender'] = gender
df['Division'] = division
df['Description'] = detail

iterations = list(range(1,100))
df_list=[]
for i in iterations:
    url = "https://www.ustfccca.org/team-rankings-polls-central/polls-rankings-hub?coll="+str(i)+"/"
    df_collection=[]
    soup = make_soup(url)
    df_collection.append(pd.read_html(soup))
    df = df_collection[0]
    df = df[0]
    req = requests.get(url)
    content=req.text
    soup2 = BeautifulSoup(content)
    year = soup2.h4.text
    detail = year[5:]
    year = year[0:4]
    season_gender = soup2.find_all("h5")[0].text
    if 'Cross' in season_gender:
        season = 'Cross Country'
    elif 'Outdoor' in season_gender:
        season = 'Outdoor Track'
    else:
        season = 'Indoor Track'
    if 'III' in season_gender:
        division = 'III'
    elif 'II' in season_gender:
        division = 'II'
    elif 'NJCAA' in season_gender:
        division = 'NJCAA'
    elif 'NAIA' in season_gender:
        division = 'NAIA'
    else:
        division = 'I'
    if 'Women' in season_gender:
        gender = 'Women'
    else:
        gender = 'Men'
    df['Year'] = year
    df['Season'] = season
    df['Gender'] = gender
    df['Division'] = division
    df['Description'] = detail
    df_list.append(df)
    
