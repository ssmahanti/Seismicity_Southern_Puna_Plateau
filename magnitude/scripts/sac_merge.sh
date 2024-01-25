#Merge the SAC traces such that each trace contains a whole day of data

for ((mon=1; mon<=1 ; mon++));
do
	for (( num=1; num<=1; num++ )); 
	do		
		mkdir ../data/sacgfz/2008.$mon.$num/merged
		echo $mon.$num | python sac_merge.py 
		#rm ./2009.$mon.$num/*.SAC
	done
done
