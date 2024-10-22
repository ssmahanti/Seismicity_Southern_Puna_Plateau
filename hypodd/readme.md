# Steps to perform for HypoDD run:

## 1. Prepare Input Files:

1. Run *./scripts/velest_hypodd.py* to create the phasefile: *phase_input_hypodd.txt*
2. Run *awk '{print($3$4,$2,$1)}' ../../station/spuna_stations.txt > station.dat* to create the Station file.

## 2. Run HypoDD:

1. Run ph2dt: *ph2dt ph2dt.inp*
2. Edit the hypoDD.inp as required. We need to shift the velocity model by the average station elevation as velest model is w.r.t sealevel. But for hypoDD, it is w.r.t average station elevation.
3. Run hypoDD
4. Remove the unused files with: *rm *.reloc.* *

## 3. Output File:

1. Follow the jupyter notebook *hypodd_analysis.ipynb* for further processing.

## 4. Resampling Test:

1. Run *hypodd_error.sh*: It generates noisy differential travel time: *dt_noisy.ct* by adding residual noise to *dt.ct* by *./scripts/dt_gen.py*. Then it runs HypoDD and stores the output in the ./output/run_puna_$i.reloc files.

2. Follow the jupyter notebook *hypodd_analysis.ipynb* for further processing.