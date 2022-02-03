#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb  2 16:20:33 2022

@author: mattyoung
"""

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


xc = ['11762', '11763','10446','10447','9270','9356','5962','5963','5946','5957','5471','5474','5003','5000','4514','4510','4095','4100','3674','3680','3330','3329']
df_list=[]
for i in xc:
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

xc_df = pd.concat(df_list)
xc_df.rename(columns = {'RANK':'Rank','Unnamed: 1':'Delete','TEAMCONFERENCE':'Team','Unnamed: 3':'Points','Unnamed: 5':'Change'}, inplace=True)
xc_df = xc_df.drop(columns={'Delete'})

df_list=[]
outdoor = ['11020','11021','8845','9008','7393','7404','5809','5810','5333','5332','4850','4848','4365','4368','3943','3946','3568','3570','3153','3151','2750','2751']
for i in outdoor:
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
    
outdoor_df = pd.concat(df_list)
outdoor_df.rename(columns = {'RANK':'Rank','Unnamed: 1':'Delete','TEAMCONFERENCE':'Team','Unnamed: 3':'Points','Unnamed: 5':'Change'}, inplace=True)
outdoor_df = outdoor_df.drop(columns={'Delete'})

df_list=[]
indoor = ['10586','10587','8076','8283','7180','7189','5627','5628','5156','5155','4668','4665','4221','4213','3800','3801','3443','3436','3034','3033','2630','2635']
for i in indoor:
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
    
indoor_df = pd.concat(df_list)
indoor_df.rename(columns = {'RANK':'Rank','Unnamed: 1':'Delete','TEAMCONFERENCE':'Team','Unnamed: 3':'Points','Unnamed: 5':'Change'}, inplace=True)
indoor_df = indoor_df.drop(columns={'Delete'})

xc_df.to_csv('xc_rank.csv', index=False)
outdoor_df.to_csv('outdoor_rank.csv', index=False)
indoor_df.to_csv('indoor_rank.csv', index=False)

