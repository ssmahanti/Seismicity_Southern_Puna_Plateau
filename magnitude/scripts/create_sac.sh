#This script extracts SAC files from mseed files to calculate the magnitude.

for ((mon=1; mon<=1 ; mon++));
do

	for (( num=1; num<=1; num++ )); 
	do
		echo "2008.$mon.$num" 
		mseed2sac ../../phasenet/dataset_gfz/2008.$mon.$num/*_mseed
		mkdir ../data/sacgfz/2008.$mon.$num
		mv *.SAC ../data/sacgfz/2008.$mon.$num
	done
done
rm *.SAC