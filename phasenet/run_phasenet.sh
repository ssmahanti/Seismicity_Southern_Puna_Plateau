#script for running phasenet in a loop for different days and months
#First activate phasenet environment by: conda activate phasenet

#Based on the dataset for version= 0.1.0:
#1. change the sampling rate in [PhaseNet folder]/main/phasenet/datareader.py
#2. change the probabilities in [PhaseNet folder]/main/phasenet/predict.py
#3. change dt=1/sampling_rate in [PhaseNet folder]/main/phasenet/visualization.py

#Run the script:
for ((m=1;m<=1;m++)) #Loop over months
do
	for ((i=1;i<=1;i++)) #Loop over days
	do	
		day=2008.$m.$i	
		echo "fname" > ./csvset_gfz/$day.csv  #Create the csv file	
		ls ./dataset_gfz/$day >> ./csvset_gfz/$day.csv	#List the datafiles in the csv file
		python ./main/phasenet/predict.py --model=./main/model/190703-214543 --data_list=./csvset_gfz/$day.csv --data_dir=./dataset_gfz/$day --result_dir=./result_gfz/$day --format=mseed --plot_figure --amplitude
		echo "done for $day"
	done
done

