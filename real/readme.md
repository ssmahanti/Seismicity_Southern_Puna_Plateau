# Steps to Run REAL and Make Initial Earthquake Catalog


## 1. Prepare Input Files (pickfiles):

1. Copy the result_gfz and result_iris folder from Phasenet folder to the pick_phasenet folder.
2. Run *run_pick.sh* for each set of picks with correct sampling rate in *picksplit.py* script.
3. We need to run *./tt_db/taup_tt.py* if we are using a heterogeneous velocity model.

## 2. Run REAL:

1. Choose the parameters in *runREAL.pl* script.
2. Run *run_perl.sh* to run the associator: REAL.

## 3. Output Files:

1. Run *./make_catalog.sh* to merge all results: The output files are stored in *catalog* folder:
	all_eq.txt : all events from real in puna crust			
	all_phase.txt: all phase arrivals for the events			
	all_phase_sa.txt : all phases after simulated annealing
	catalog_sa.txt : event catalog after simulated annealing

2. For space limitations, till now, the repository includes the analysis of data from 20080101.

3. For further use, the complete catalog is given in *catalog_real_puna_crust.txt* file.
