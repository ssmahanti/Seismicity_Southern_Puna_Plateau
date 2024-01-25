#Velest: series of scripts

#remove leading blankline in the files (if any)

#Prepare phase file
cat ../../real/catalog/all_phase.txt | awk '{print $1}'>temp.txt
paste temp.txt ../../real/catalog/all_phase_sa.txt > ../phase_real_puna_crust.txt
rm temp.txt
