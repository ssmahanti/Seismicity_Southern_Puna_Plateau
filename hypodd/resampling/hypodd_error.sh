
for ((i=1; i<=2;i++))
do
	python dt_gen.py
	hypoDD hypoDD_resamp.inp
	mv hypodd_puna_n.reloc ./output/run_puna_$i.reloc
	rm *.reloc.*
done