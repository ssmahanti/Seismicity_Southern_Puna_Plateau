#Run LOTOS for different damping parameters

datahome="/Users/sankha/Desktop/research/southern_puna_git/lotos/am_sm/r1/DATA/PUNASLP1/REAL_001"

for a in $(seq 0 0.5 10)
do
	#echo $i
	echo "damp= $a"
	cat $datahome/MAJOR_PARAMi.DAT| awk -v d=$a '{ if ( NR ==30 ) $1=d ;print $0}'  > $datahome/temp.inp. #check the line number for the file
	cat $datahome/temp.inp | awk -v d=$a '{ if ( NR ==30 ) $2=d ;print $0}'  >$datahome/MAJOR_PARAM.DAT

	./start.sh>./log/log_damp_$a.txt

done

rm temp.inp