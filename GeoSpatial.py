#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Mar 28 21:55:43 2022

@author: mattyoung
"""

import plotly.graph_objects as go
import pandas as pd

df2 = pd.read_csv("XC_Team_Elevation.csv")


df = pd.DataFrame([['Air Force',38.998357, -104.861753, 6000], ['Alabama',33.215775, -87.538261, 100], ['Arizona', 32.2319, -110.9501, 4000], ['Arkansas', 36.0687, -94.1748, 1000]],
    columns = ['Name', 'Lat', 'Long', 'Altitude'])

df['text'] = df['Name'] + " " + df["Altitude"].apply(str) + ' ft'

df_scaled = df

df_scaled['Altitude'] = (df_scaled['Altitude'] - df_scaled['Altitude'].min())/(df_scaled['Altitude'].max() - df_scaled['Altitude'].min())

df_scaled['Altitude'] = (df_scaled['Altitude'] + .1) * 30


fig = go.Figure(data=go.Scattergeo(
    lon = df_scaled['Long'],
    lat = df_scaled['Lat'],
    text = df_scaled['text'],
    mode = 'markers',
    marker = dict(
        color = "red",
        size = df_scaled['Altitude'])
    ))

fig.update_layout(
    title = 'NCAA XC School Locations',
    geo_scope = 'usa',)

fig.write_html("test.html")

