#This script organises the Geofon data in daywise folders.

for ((m=1;m<=1;m++))
do
	for ((i=1;i<=1;i++))
	do
		mkdir ../dataset_gfz/2008.$m.$i
		mon=$(printf "%02d\n" $m);
		day=$(printf "%02d\n" $i);
		mv 2008_${mon}_${day}_*_mseed  ../dataset_gfz/2008.$m.$i
	done
done
