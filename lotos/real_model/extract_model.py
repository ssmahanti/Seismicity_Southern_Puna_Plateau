#This script adds the absolute velocity to the model files and calculates the percentage variation
#Also the model is converted to coordinates
#First clean up the model file from additional information. It should only contain the five columns
#Remove the first line of refmod.dat

#Import relevant libraries
import numpy as np
import pygmt
import pandas as pd
from scipy.interpolate import interp1d
from functools import reduce
import matplotlib.pyplot as plt
from math import *

######################Add the absolute velocity with the anomaly using refmod.dat########################

#Run for P and S separately

fo=open("dv3D_run_abs_s.dat",'w') #output file
df_mod=pd.read_csv("refmod.dat", sep="\s+",header=None) #reference 1D model file


f1=interp1d(df_mod[0],df_mod[2]) #Interpolate either P=1 or S=2 velocity
dzt=np.arange(-4,21,1) #Check Z range in major_param.dat
dvt=f1(dzt) #Interpolate at Z values

df_obt=pd.read_csv("dv3D_run.dat",sep="\s+",header=None)  #model file

#Adds a column of absolute velocity and change in velocity in percent.
k=0
for i in range(len(df_obt[0])):   
    if df_obt[0][i]==2: #P=1 or S=2
        print(df_obt[0][i],df_obt[1][i],df_obt[2][i],df_obt[3][i],df_obt[4][i],dvt[k],(df_obt[4][i]/dvt[k])*100,file=fo)
        k=k+1
        if k%25==0: #be careful for each file
            k=0
fo.close()
######################Nodes to coordinates for velocity model############################################################################
#
lat0=-26.7
lon0=-67.1
dep0=-4.0

df_real = pd.read_csv("dv3D_run_abs_s.dat",sep="\s+",header=None) #P or S file

a1=4.0/110.574
a2=4.0/(111.320*cos(lat0*pi/180))
lonlist=round((lon0+(df_real[1]-36)*a2),4)
latlist=round((lat0+(df_real[2]-36)*a1),4)
deplist=(dep0+df_real[3]-1)

# initialize data of lists.
data = {0: lonlist,1: latlist,2:deplist,3:df_real[4],4:df_real[5],5:df_real[6]}

# Create DataFrame
df = pd.DataFrame(data)
print(df)
df.to_csv("velmodel_coord_s.dat",sep=" ",index=False,header=None)



