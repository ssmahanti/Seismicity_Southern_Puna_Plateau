#This script labels the focal mechanisms as normal/thrust/strike-slip based on P and T axes orientation.

#!/usr/bin/env python
# coding: utf-8

# In[20]:

from pyrocko import moment_tensor as pmt
import numpy as num
from obspy.imaging.beachball import beachball
import pandas as pd

fo=open("focmec_category.dat",'w')
df=pd.read_csv("focmec_axes_v2.dat", sep='\s+', header=None)
print(df)
for i in range(len(df[0])):
    p_dip=df[9][i]
    t_dip=df[11][i]
    if abs(p_dip)<45 and abs(t_dip)<45:
        df[12][i]=1
    elif abs(p_dip)>45 and abs(t_dip)<45:
        df[12][i]=2
    elif abs(p_dip)<45 and abs(t_dip)>45:
        df[12][i]=3
        
df.to_csv('focmec_category.csv', index=False)      
    


# In[ ]:




