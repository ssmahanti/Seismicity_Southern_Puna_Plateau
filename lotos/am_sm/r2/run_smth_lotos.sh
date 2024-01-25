#Run LOTOS for different smoothing values

datahome="./DATA/PUNASLP1/REAL_001"

for a in $(seq 0.0 0.5 10)
do
	echo "smth= $a"
	cat $datahome/MAJOR_PARAMi.DAT| awk -v d=$a '{ if ( NR ==29 ) $1=d ;print $0}'  > $datahome/temp.inp. #check the line number
	cat $datahome/temp.inp | awk -v d=$a '{ if ( NR ==29 ) $2=d ;print $0}'  >$datahome/MAJOR_PARAM.DAT

	./start.sh>./log/log_smth_$a.txt
done
rm temp.inp