##Run this file to create the necessary input files for LOTOS run
#1. rays.dat
#2. stat_ft.dat
#3. ref_start.dat


#####input phase file#########
python velest_2_lotos_1.py
python velest_2_lotos_2.py 

####Input station file#########

awk '{print $2,$3,-$4}' station_v2.txt > stat_ft.dat


#####Input velocity model file########
./inputvel.sh

rm lotos_temp1.txt