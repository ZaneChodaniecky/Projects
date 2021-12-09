# -*- coding: utf-8 -*-
"""
Created on Wed Dec  8 18:20:11 2021

@author: Zane
"""

import pandas as pd
import seaborn as sns

data2016 = pd.read_csv('crime-incident-reports-2016.csv')
data2017 = pd.read_csv('crime-incident-reports-2017.csv')
data2018 = pd.read_csv('crime-incident-reports-2018.csv')

list_of_dataframes = [data2016, data2017, data2018]

df = pd.concat(list_of_dataframes)

# Explore the dataframe
print(df.describe())
print(df.dtypes)
print(df.isnull().any())
print((df.isnull().sum()/df.shape[0])*100)
print(df.isnull().sum())

df.drop(['Location'], axis = 1, inplace = True)

# Visual check of which columns are missing significant data
colors = ['#000099', '#ffff00']
sns.heatmap(df.isnull(), cmap=sns.color_palette(colors))

# Fix inconsistent boolean values in shooting column
print(df['SHOOTING'].unique())

# Fill nan with appropriate values
dict_fillna = {'SHOOTING':0, 'Lat':0, 'Long':0, 'STREET':'Missing','UCR_PART':'Missing',
               'DISTRICT':'Z1'}
df = df.fillna(dict_fillna)

# Replace invalid values
df['SHOOTING'].replace({'Yes':1,'Y':1,'No':0}, inplace= True)
df['REPORTING_AREA'].replace(' ', -999, inplace = True)
df['Lat'].replace(-1, 0, inplace = True)
df['Long'].replace(-1, 0, inplace = True)

# Title case street names
df['STREET'] = df['STREET'].str.title()

# Export to csv
df.to_csv('crime-incident-reports-2016-2018-clean.csv', index=False)



