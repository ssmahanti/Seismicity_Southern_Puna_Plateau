#This script compares the station name with the station list and puts the station number for each phase
#and 1/2 for P/S. It also counts the number of phases for each event to be added in next script.
#Writes the number of phases on the event line

fi=open("lotos_temp1.txt",'r')  #input file
fi2=open("station_v2.txt",'r')  #station file
fo=open("rays.dat",'w')  #rays.dat output file

l1=fi.readlines()
l2=fi2.readlines()

for i in range(len(l1)):
	jk=l1[i].split()[0]
	if jk=="#":
		cnt=0
		#count number of phases
		for j in range(i+1,len(l1)):
			jk2=l1[j].split()[0]
			if jk2!=jk:
				cnt+=1
			else:
				break					
		
		lat=l1[i].split()[1]
		lon=l1[i].split()[2]
		dep=l1[i].split()[3]
		print (lon,"	",lat,"   ",dep,"   ",cnt,file=fo)  #event line
	else:
		stn=l1[i].split()[0]
		for j in range(len(l2)):
			stnname=l2[j].split()[0]
			if stnname==stn:	#matches station with station number
				stnnum=j+1

		tt=l1[i].split()[2]   #travel time
		phs=l1[i].split()[1]  #phase	
		if phs=="P":
			nk=1
		else:
			nk=2
		print("	",nk,"	",stnnum," ",tt,file=fo)	#phase line



