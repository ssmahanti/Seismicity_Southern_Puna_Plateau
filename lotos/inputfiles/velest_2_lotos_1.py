#This script takes the output cnv file from velest and extracts out the events and phases

fi=open("inpmd_const_puna_v2.CNV",'r')   #Output file from velest
fo=open("lotos_temp1.txt",'w')   #temporary output file

lines=fi.readlines()
c=0
for i in range(len(lines)):
	m=lines[i]
#	res=lines[i][63:66]
	if(m[0:2]==" 8" or m[0:2]==" 9"):  #event lines
		lat=float(m[17:25])*-1
		lon=float(m[27:35])*-1
		dep=float(m[37:43])
		res=float(m[63:67])
		az=int(m[54:58])
		#num=int(m[45:48])

		#Selecting events based on gap, azimuth and depth
		if(int(az)<=180 and float(res)<1.0 and float(dep)<40.1):
			c=1
			print("#",lat,lon,dep,az,res,file=fo)
		else:
			c=0

	else:    #phase lines
		for j in range(6):
			kk=14*j
			stn=m[kk:kk+6]
			phs=m[kk+6:kk+7]
			tt=m[kk+9:kk+14]
			if(len(stn)==6 and c==1):

				print(stn,phs,tt,file=fo)