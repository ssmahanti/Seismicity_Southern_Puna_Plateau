#Script for running REAL associator in iteration over days

for ((mon=1; mon<=1 ; mon++));
do

	for (( num=1; num<=1; num++ )); 
	do 
		month=$(printf "%02d\n" $mon);
		day=$(printf "%02d\n" $num);
		echo $month$day
		inp=$(printf $month"_"$day)

		perl runREAL.pl <<< $inp #Run the REAL code

		mkdir ./result_real_puna/2008$month$day
		mv *.txt  ./result_real_puna/2008$month$day
		mv *.dat  ./result_real_puna/2008$month$day
	done
done

