#This scripts pulls out the events with magnitudes from the puna_mag_real_v5.txt catalog which are present in HypoDD or Velest catalog

#Input files
#fi1=open('../hypodd/output/catalog_hypodd_puna_crust_v5.txt','r')  # hypodd Catalog
#fi1=open('../real/catalog/catalog_real_puna_crust_v5.txt','r')  #Real Catalog
fi1=open('../velest/output/catalog_velest_puna_crust_v5.txt','r')  #Velest Catalog

fi2=open('puna_mag_real_v5.txt','r')  #Magnitude list

#Output files
fo=open('puna_catalog_velest_v5.txt','w') #magnitudes of catalog events
fo2=open('puna_nomatch_velest_v5.txt','w') #Catalog events for which no magnitude was found in the magnitude list

line=fi1.readlines()
line2=fi2.readlines()

for i in range(len(line)):  #The event catalog

	#year,mon,day,hr,mn,sec,lat,lon,dep,aa,np,az,res,num=line[i].split() #For real
	year,mon,day,hr,mn,sec,lat,lon,dep,num,az,res=line[i].split() #For velest
	#year,mon,day,hr,mn,sec,lat,lon,dep,res=line[i].split()  #For hypoDD

	print(year,mon,day,hr,mn,sec,lat,lon,dep,res)
	count=0

	for j in range(len(line2)): #Magnitude catalog
		num,year2,mon2,day2,hr2,mn2,sec2,lat2,lon2,dep2,mag,resmag=line2[j].split()
		
		t1=(int(hr))*3600 + int(mn)*60 + float(sec)
		t2=int(hr2)*3600 + int(mn2)*60 + float(sec2)
		err=abs(t1-t2)

		if (2000+int(year)==int(year2)) and (int(mon)==int(mon2)) and (int(day)==int(day2)) and err<5:	 #For velest	
		#if (int(year)==int(year2)) and (int(mon)==int(mon2)) and (int(day)==int(day2)) and err<5:	     #For hypodd/real	

			print(year2,mon,day,hr,mn,sec,lat,lon,dep,res,mag,resmag,file=fo)
			count=1
	if count==0:
		print(year,mon,day,hr,mn,sec,lat,lon,dep,num,az,res,file=fo2)