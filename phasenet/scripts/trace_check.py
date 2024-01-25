#This script prints trace details in the data for a day to check if there are any defective trace.
from obspy import read

for i in range(1,2): #Loop over months
	for j in range(1,2): #Loop over days
			try:
				st=read("../dataset_gfz/2008.%d.%d/*_mseed"%(i,j))
				#print(st)			
				for i in range(len(st)):
					print(st[i].stats.station,st[i].stats.channel,st[i].stats.starttime,st[i].stats.endtime,st[i].stats.sampling_rate)

			except:
				print("problem for",i,j )		