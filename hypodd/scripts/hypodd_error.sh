
for ((i=1; i<=2;i++))
do
	python dt_gen.py
	#hypoDD ../resampling/hypoDD_resamp.inp
	#mv hypodd_puna_n.reloc ../resampling/output/run_puna_$i.reloc
	#rm *.reloc.*
done