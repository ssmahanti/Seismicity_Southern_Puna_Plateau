#script for running phasenet in a loop for different days and months
for ((m=1;m<=1;m++))
do
	for ((i=1;i<=1;i++))
	do	
		day=2008.$m.$i	
		echo "fname" > ./csvset_gfz/$day.csv	
		ls ./dataset_gfz/$day >> ./csvset_gfz/$day.csv	
		python ./main/phasenet/predict.py --model=./main/model/190703-214543 --data_list=./csvset_gfz/$day.csv --data_dir=./dataset_gfz/$day --result_dir=./result_gfz/$day --format=mseed --plot_figure --amplitude
		echo "done for $day"
	done
done

