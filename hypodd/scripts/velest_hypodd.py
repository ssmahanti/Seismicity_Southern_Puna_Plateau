#This script takes the output cnv file from velest and extracts out the events and phases

fi=open("../../velest/model/inpmd_const_puna_v2.CNV",'r')
fo=open("../phase_input_hypodd.txt",'w')
lines=fi.readlines()
c=0
k=0
for i in range(len(lines)):
	m=lines[i]
#	res=lines[i][63:66]
	if(m[0:2]==" 8" or m[0:2]==" 9"):
		year=int(m[0:2])
		mon=int(m[2:4])
		day=int(m[4:6])
		hr=int(m[7:9])
		mm=int(m[9:11])
		ss=float(m[12:18])
		lat=float(m[17:25])*-1
		lon=float(m[27:35])*-1
		dep=float(m[37:43])+3.1  #Added average station elevation as in HypoDD, depth is w.r.t average station elevation
		#num=float(m[46:49])
		res=float(m[63:67])
		az=int(m[54:58])
		#print(num)
		#Selecting events based on gap, azimuth and depth
		k+=1
		if(int(az)<=180 and float(res)<1.5 and float(dep)<40.1):
			c=1
			
			print("#","200%d" %(year),"","%02d"%mon,"","%02d"%day," ","%02d"%hr,"  ",mm,"  ",ss,"  ",lat,"  ",lon,"  ",dep,"   ",0.0,"   ",0.0,"   ",0.0,"  ",res," ",k,file=fo)
		else:
			c=0
#		print(lines[i][0:43],file=fo)
	else:
		for j in range(6):
			kk=14*j
			stn=m[kk:kk+6]
			phs=m[kk+6:kk+7]
			tt=m[kk+9:kk+14]
			if(len(stn)==6 and c==1):

				print(stn,tt,1,phs,file=fo)
		
#print(c)