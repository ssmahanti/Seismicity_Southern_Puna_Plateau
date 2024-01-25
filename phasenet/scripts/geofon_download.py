#This script downloads GFZ dataset for each day using Pyrocko module. This is followed by ./geofon_data_org.sh for organising in daily folders.

#Import relevant libraries
from pyrocko.client import fdsn
from pyrocko import util, io, trace, model
from pyrocko.io import quakeml

#Read station files
stnfile=open("../../station/2B_stations.txt",'r')
stations=stnfile.readlines()
#stations=["GALAN"]

#Loop over months and days
for mon in range(1,2):
    for stn1 in stations:
        stn=stn1.strip()
        print(stn)
        for day in range(1,2):
            try:
                tmin = util.stt('2008-%02d-%02d 00:00:00.000'%(mon,day)) #starttimr
                tmax = util.stt('2008-%02d-%02d 23:59:59.999'%(mon,day)) #Endtime

# download data from GEOFON website
                selection = [('2B', '%s'%stn, '*', 'HH*', tmin, tmax)]
                request_waveform = fdsn.dataselect(site='geofon', selection=selection)

# write the data stream
                with open('2008_%02d_%02d_000000.00_2B_%s_mseed'%(mon,day,stn), 'wb') as file:
                    file.write(request_waveform.read())
                    
                print("done for station %s month %d day %d"%(stn,mon,day) )    
            except:
                print("There is some problem for station %s month %d day %d"%(stn,mon,day))




