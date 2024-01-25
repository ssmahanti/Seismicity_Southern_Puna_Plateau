#This script prepares the pickfiles for REAL from csv files of Phasenet picks
#change the sampling rate in picksplit.py for each set of data


for ((i=1;i<=1;i++)) #Loop over months
do
	for ((j=1;j<=1;j++)) #Loop over days
	do
		fname=$(printf "2008%02d%02d\n" $i $j)
		day=2008.$i.$j

		if [ -d "./result_gfz/$day" ]  #if the directory exists in phasenet results
			then
    		echo "Directory $day exists." 

			python picksplit.py <<< 2008.$i.$j
			pick2real -Ptemp.p -Stemp.s

			#Create this directory for the first set of data. Then append for other datasets.
			#mkdir ./pickfiles/$fname/
			mv ./$fname/* ./pickfiles/$fname/			
		else
    		echo "Directory $day does not exists."	
		fi
	done

done
