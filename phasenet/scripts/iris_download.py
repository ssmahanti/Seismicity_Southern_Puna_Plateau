#This script extracts the daily data from the merged mseed files dowloaded from IRIS and organises in daywise folders.
#Written by SS Mahanti

#First, the mseed files need to be downloaded from IRIS DMC using breqfast request.

#Import relevant libraries
import os
import shutil
from obspy import *
import matplotlib  
matplotlib.use('TkAgg') 

parent_tg_dir="../dataset/"

#Read the station file
stnfile=open("../../stations/X6_stations.txt",'r')
stations=stnfile.readlines()

#Loop over stations
for stn1 in stations:
    stn=stn1.strip()
    print(stn)

    for month in range(1,2): #Loop over moths
    	for day in range(1,31): #Loop over days
    		direc="2009.%d.%d"%(month,day)
    		path=os.path.join(parent_tg_dir,direc)
    		if not os.path.exists(path):
    			os.mkdir(path)
    		try:
    			print("trying for station %s month %d day %d"%(stn,month,day))
    			st=read("./raw_data/X64.765071/%s.X6.mseed"%stn). #Read the downloaded mseed files
    			dt = UTCDateTime("2009-%02d-%02dT00:00:00"%(month,day))
    			st.trim(dt, dt + 86400)
    			try:
    				st.write('../dataset/2009.%d.%d/2009_%02d_%02d_000000.00_X6_%s_mseed'%(month,day,month,day,stn), format='MSEED')
    				print("done for stn %s month %02d day %02d" %(stn,month,day))
    			except:
    				print("no data for stn %s month %02d day %02d" %(stn,month,day))
    		except:
    			print("No data for this station")
	