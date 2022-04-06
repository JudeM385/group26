#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 28 21:55:43 2022

@author: mattyoung
"""
import plotly
import plotly.graph_objects as go
import plotly.express as px
import pandas as pd

df_full = pd.read_csv("Merged_Ranking_Lat_Long.csv")
dfconference = df_full.iloc[:,[1,3]]
dfgeoelevation = pd.read_csv("Altitude_Data/XC_Team_Elevation_Lat_Long.csv")
dfsuccess = pd.read_csv("Ranking_Data/team_caliber.csv")

df = dfgeoelevation.merge(dfsuccess, how='left')
df = df.merge(dfconference, how='right')

df['text'] = df['Team'] + ", " +df['Conference'] + " Conference, " + df["elevation"].apply(str) + ' ft. elevation'

df_scaled = df

df_scaled['elevation'] = (df_scaled['elevation'] - df_scaled['elevation'].min())/(df_scaled['elevation'].max() - df_scaled['elevation'].min())

df_scaled['elevation'] = (df_scaled['elevation'] + .3) * 20


fig = go.Figure(go.Scattergeo(
    lon = df_scaled['long'],
    lat = df_scaled['lat'],
    text = df_scaled['text'],
    mode = 'markers',
    marker = dict(
        size = df_scaled['elevation'],
        color = df_scaled['team_performance'],
        colorscale = 'RdBu',
        colorbar_title="Overall Team Performance in the Past 10 Years")
    ))



fig.update_layout(
    title = 'NCAA XC School Success by Altitude <br> (Higher Elevation by Size) <br> (Hover for details)',
    geo_scope = 'usa',
    template = 'plotly_dark')

fig.write_html("AltitudeSuccess.html")

