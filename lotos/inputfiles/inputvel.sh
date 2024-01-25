#Reformat the files for plotting
echo "0.00 \t        Ratio vp/vs  " > ref_start.dat

model=inpmd_const_puna_v2.mod

#########################
cat $model | awk '{if (NR>2 && NR<18) print $2,'\t',$1}'>temp_mod1.txt 
cat $model | awk '{if (NR>18 && NR<34) print $1}' >temp_mod2.txt
#cat temp1.txt
paste temp_mod1.txt temp_mod2.txt>>ref_start.dat
rm temp_mod1.txt temp_mod2.txt
#cat ref_start.dat
