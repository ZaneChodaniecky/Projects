# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 17:30:07 2021

@author: Zane
"""
import pandas as pd
import numpy as np
from datetime import date

df = pd.read_csv('crime-reports.csv')


df.columns
df.dtypes
df.isnull().any()
df.isnull().sum()
df.isnull().sum()/df.shape[0] * 100

df[['Street', 'City', 'State']] = df['Location'].str.split(',', expand=True)

df.drop(['Location','Crime Date Time'], axis = 1, inplace = True)

df.dropna(inplace = True)

# Check each crime value
df.Crime.unique()

# Count how many crime as missing due to Admin Error
print(df[df['Crime'] =='Admin Error'].shape[0])

# Drop Admin Error rows
df = df[df['Crime'] != 'Admin Error']

# Had previously removed the '0 ' from some street names. Now I realize that is a naming convention for the block
##df['Street'] = np.where(df['Street'].str[0:2] == '0 ', df['Street'].str[2:].str.title(), df['Street'].str.title())

# Title case the street
df['Street'] = df['Street'].str.title()


# Split datetime into separate columns and remove
df['Date of Report'] = pd.to_datetime(df['Date of Report'])
df['Date'] = df['Date of Report'].dt.date
df['Year'] = df['Date of Report'].dt.year
df['Month'] = df['Date of Report'].dt.month
df['Weekday'] = df['Date of Report'].dt.weekday
df['Hour'] = df['Date of Report'].dt.hour
df['Minute'] = df['Date of Report'].dt.minute

# Replace alias for weekdays
weekday_dict = {0:'Monday',1:'Tuesday', 2:'Wednesday', 3:'Thursday', 4:'Friday', 5:'Saturday', 6:'Sunday'}
df['Weekday'].replace(weekday_dict, inplace = True)

df.drop(['Date of Report'], axis = 1, inplace = True)

# Export to csv
df.to_csv('crime-reports-clean-' + str(date.today()) + '.csv', index = False)

