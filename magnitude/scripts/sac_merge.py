#Merge the SAC traces such that each trace contains a whole day of data

from obspy import *

inp=input()
mon=int(inp.split('.')[0])
day=int(inp.split('.')[1])
#print(mon)

stnfile=open("../../station/2B_stations.txt",'r')
stations=stnfile.readlines()
#stations=["GALAN"]
for stn in stations:
		stn1=stn.strip()
		for chnl in ["N","E","Z"]:
			try:
				st=read("../data/sacgfz/2008.%d.%d/2B.%s..HH%s.D.*.SAC"%(mon,day,stn1,chnl))
				st.merge(method=0, fill_value=0)
				st.write("../data/sacgfz/2008.%d.%d/merged/2B.%s..HH%s.D.2008.%d.%d.SAC"%(mon,day,stn1,chnl,mon,day))
				print("Written for 2008.%d.%d station %s channel HH%s"%(mon,day,stn1,chnl))
			except:
				print("Data not available for 2008.%d.%d station %s channel HH%s"%(mon,day,stn1,chnl))