# Steps for Local Earthquake Tomography with Velest:

Copy the required program files from the LOTOS package to the run folders.

## Prepare Input files:

1. Copy the final .CNV and .mod file from Velest to *inputfiles* folder.
2. Run *./inputfiles/inputfiles.sh* to prepare the three input files: *rays.dat, stat_ft.dat, ref_start.dat*.
3. Copy *rays.dat, stat_ft.dat* to *./DATA/PUNASLP1/inidata*
4. Copy *ref_start.dat* to *./DATA/PUNASLP1/REAL_001*

## Run LOTOS:

1. Modify *all_areas.dat* as needed for model and number of iterations.
2. Modify *./DATA/PUNASLP1/REAL_001/MAJOR_PARAM.DAT* as needed for twaeking parameters.
3. Run *./run_lotos.sh* to run LOTOS.

## Find optimum damping and smoothing value:

To find the best damping and smoothing values from Model variance vs Data variance curve:
1. Run *./am_sm/r1/run_damp_lotos.sh* to try different damping values.
2. Run *./am_sm/r2/run_smth_lotos.sh* to try different smoothing values.
3. Follow the notebook *am_sm.ipynb* to process the output file and plot the L-curves.

## Process model file:

1. Clean up the model and refmod.dat file so that it only contains the five columns associated with the model.
2. Run *python ./real_model/extract_model.py* to obtain the 3D model in Geographical coordinates.

## Checkerboard Test:

1. Run LOTOS for the model ./DATA/PUNASLP1/SYNTH001 for checkerboard test. Update *all_areas.dat* accordingly.
2. Added noise is defined in noise.dat
3. The checkerboard anomaly is defined in *anomaly.dat*.

## Semblence Test:

To calculate the semblance of the model with input checkerboard, seven checkerboard tests are run by shifting the checkerboard horizontally and vertically. These are defined as:
	r1: neutral checkerboard
	r2: shifted by 2 nodes to positive X-direction.
	r3: shifted by 2 nodes to negative X-direction.
	r4: shifted by 2 nodes to positive Y-direction.
	r5: shifted by 2 nodes to negative Y-direction.
	r6: shifted by 2 nodes to downward Z-direction.
	r7: shifted by 2 nodes to upward Z-direction.

1. Use the anomaly files in *./checkerboard_test/anomalies* and copy it to *./DATA/PUNASLP1/SYNTH001/anomaly.dat* for each run.
2. Follow the *./checkerboard_test/checkerboard_analysis.ipynb* notebook to calculate the semblance and average semblance.
3. The results are stored in *./checkerboard_test/check20_20_8*

## Output files:

1. velmodel_coord_p.dat : P-velocity model.
2. velmodel_coord_s.dat : S-velocity model.
3. semblance_average_chk20_coord_comb.dat: Semblance value for each node. The minimum between P and S semblance is taken.
4. checkerboard_20_coord_input.dat: Input checkerboard
