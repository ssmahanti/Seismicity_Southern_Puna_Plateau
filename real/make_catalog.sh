#This script collects all the catalog/ and phases to one file.

#Uncomment the first 4 lines when running for 2008 and comment out for 2009 for overwriting the files.
#adjust the months accordingly
#The catalog_sa.txt is used for further processing

#echo " "> ./catalog/all_eq_v2.txt
#echo " ">./catalog/catalog_sa_v2.txt     #catalog after simulated annealing step
#echo " "> ./catalog/all_phase_v2.txt   
#echo " "> ./catalog/all_phase_sa_v2.txt

totaleq=0
for ((mon=1; mon<=9 ; mon++));
do
	for (( num=1; num<=31; num++ )); 
	do 
		direc=$(printf "2009%02d%02d\n" $mon $num);
		echo $direc 
		eqn=$(cat ./result_real_puna/$direc/catalog_sel.txt | wc -l)
		totaleq=$(( totaleq + eqn))
		echo $totaleq
		cat ./result_real_puna/$direc/catalog_sel.txt | awk  '{print $0}' >>./catalog/all_eq.txt
		cat ./result_real_puna/$direc/hypolocSA.dat | awk  '{print $0}' >>./catalog/catalog_sa.txt
		cat ./result_real_puna/$direc/phase_sel.txt | awk  '{print $0}' >>./catalog/all_phase.txt
		cat ./result_real_puna/$direc/hypophase.dat| awk  '{print $0}' >>./catalog/all_phase_sa.txt


	done
done


