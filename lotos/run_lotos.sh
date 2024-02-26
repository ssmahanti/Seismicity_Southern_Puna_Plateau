#Run this script to run LOTOS algorithm and extract the 3D velocity file

#Run LOTOS
./start.sh

#Extract the 3D Model file:

cd ./PROGRAMS/2_INVERS_3D/8n_3D_model
./mod_3D.exe>../../../real_model/dv3D_run.dat

cp ./DATA/PUNASLP1/REAL_001/data/refmod.dat ./real_model/