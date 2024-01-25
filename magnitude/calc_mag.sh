#Estimate the magnitude of the events

echo " " > puna_mag_real_2008.txt

for ((mon=1; mon<=1 ; mon++));
do
	for (( day=1; day<=1; day++ )); 
	do
		python calc_mag.py<<<2008.$mon.$day
		awk '{print $0}' puna_mag.txt >> puna_mag_real_2008.txt
	done
done