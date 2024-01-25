#This script prepares input phase files for magnitude calculation and prepares the magcalc.txt file in the result folders

for ((mon=1; mon<=1 ; mon++));
do
	for (( num=1; num<=1; num++ )); 
	do 
		direc=$(printf "2008%02d%02d\n" $mon $num);
		cat ../../real/result_real_puna/$direc/phase_sel.txt | awk '{print $1}' > ../../real/result_real_puna/$direc/temp.txt
		paste -d ' ' ../../real/result_real_puna/$direc/temp.txt ../../real/result_real_puna/$direc/hypophase.dat > ../../real/result_real_puna/$direc/temp1.txt

		cat ../../real/result_real_puna/$direc/temp1.txt | awk '{if($2 == "#") 
		print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16; else print $0;}' > ../../real/result_real_puna/$direc/magcalc.txt

		echo "EOF" >> ../../real/result_real_puna/$direc/magcalc.txt

		rm ../../real/result_real_puna/$direc/temp*.txt 
	done
done
