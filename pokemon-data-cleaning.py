# -*- coding: utf-8 -*-
"""
Created on Fri Dec 10 16:31:27 2021

@author: Zane
"""

import pandas as pd
import numpy as np
import itertools 
from datetime import date

df = pd.read_csv('Pokemon\pokemon-data.csv')

pd.set_option('display.max_columns', None)
df.columns
df.isnull().sum()
df.dtypes

# Rename columns for cleaner convention
rename_col_dict = {'#':'Pokedex_Num', 'Type 1':'Type_1', 'Type 2':'Type_2', 'Total':'Stat_Total',
                   'Sp. Atk':'Sp_Atk','Sp. Def':'Sp_Def'}
df.rename(columns=rename_col_dict, inplace = True)

# Replace male/female symbols with the words
df.Name.replace({'â™€':'(female)','â™‚':'(male)'}, inplace = True)

# Create column for combination of Type1 and Type2
df['Type_Combo'] = np.where(df.Type_2.isnull(), df.Type_1, df.Type_1 + '/' + df.Type_2)

# Create column for Mega or Primal
df['Mega_Primal'] = np.where(df.Name.str.contains('Mega |Primal ') == False,
                             'FALSE', 'TRUE')

# Fill the nulls in Type 2 with Type 1 value as key for next steps
df.Type_2.fillna(df.Type_1, inplace = True)

# Create column for combination of both types
unique_types = df.Type_1.unique()
type_list = unique_types.tolist()
type_list.sort()

# Create list of all unique type combinations
combos = list(itertools.combinations(type_list, 2))
pairs = [[x, y] for x in combos for y in combos if not set(x).intersection(set(y))]
unique_type_combos = list(set(sum(pairs, [])))

# Add same type 1 and type 2 to combo list then sort
for x in type_list:
    unique_type_combos.append((x,x))
unique_type_combos.sort()

# Create dataframe of unique type matching values, regardless which type is 1st or 2nd
df_types = pd.DataFrame(unique_type_combos, columns=['Type_1', 'Type_2'])
df_types.sort_values(by=['Type_1','Type_2'], inplace = True)
df_types['Combo_Type_Id'] = np.arange(1,len(df_types)+1)
df_types_adj = pd.merge(df, df_types, on=['Type_1', 'Type_2'], how='left')
df_final = df_types_adj.merge(df_types, left_on=['Type_1','Type_2'],right_on=['Type_2','Type_1', ], how='left')
df_final.Combo_Type_Id_x.fillna(df_final.Combo_Type_Id_y, inplace = True)
df_final.drop(['Combo_Type_Id_y', 'Type_2_y', 'Type_1_y'], axis = 1, inplace = True)
df_final.rename(columns={'Type_1_x':'Type_1','Type_2_x':'Type_2','Combo_Type_Id_x':'Combo_Type_Id'}, inplace=True)

# Change Type 2 back to None if same as Type 1
df_final['Type_2'] = np.where(df_final.Type_2 == df_final.Type_1, 'None', df_final.Type_2)

# Set coordinates to plot types in a chart
coordinates_list = np.arange(1,19)
coordinates_dict = {type_list[i]: coordinates_list[i] for i in range(len(type_list))}
df_types['X_axis'] = df_types['Type_1']
df_types['Y_axis'] = df_types['Type_2']
df_types['X_axis'].replace(coordinates_dict, inplace = True)
df_types['Y_axis'].replace(coordinates_dict, inplace = True)

# Clean of Type Id table and add columns for both type combos for a given Id
df_types['Type_Combo_1'] = df_types.Type_1 + '/' + df_types.Type_2
df_types['Type_Combo_2'] = df_types.Type_2 + '/' + df_types.Type_1
df_types.rename(columns={'Type_1':'X_axis_label','Type_2':'Y_axis_label'}, inplace=True)

# Export to csv
df_final.to_csv('Pokemon\pokemon-data-clean-'+ str(date.today()) + '.csv', index = False)
df_types.to_csv('Pokemon\pokemon-type_id-'+ str(date.today()) + '.csv', index = False)
