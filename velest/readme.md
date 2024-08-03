# Steps For VELEST:

## 1. Input File Preperation:

1. Last station in the station file *spuna_stations.txt* works as the reference station.
2. Run the *mergetogether_phase.pl* and *convertformat.pl* scripts from https://github.com/Dal-mzhang/REAL.git to prepare the input phase file and station file.


## 2. Run VELEST:

1. Input: puna_crust.pha, spuna.sta, inpmd_const.mod
2. Edit the *velest.cmn* file as required. Modify the Number of earthquakes.
3. Install and run *velest* for 10 iterations with invertratio=3 and followed by 12 iterations with invertratio=1

## 3. Output:

1. Run *convertoutput.pl* from https://github.com/Dal-mzhang/REAL.git to make the catalog.
2. Run *mv velout.mod ./output/velmodel_final.mod*

## 4. Different Starting Models:

1. Start with a very low and a very high starting model to check the robustness of the model. Run the velest similarly in the *testlow* and *testhigh* folders.

## 5. Hypocenter Stability Check:

1. Randomly shift the hypocenters by 10 km following the jupyter notebook *velest_analysis.ipynb*.
2. Now run *selectphase.pl* script modified from https://github.com/Dal-mzhang/REAL.git to include the new hypocenters to phasefile.
3. Run *convertformat.pl* again to make velest input file and Run velest inside hyposhift folder.
4. Compare and check the hypocenter shift using the jupyter notebook *velest_analysis.ipynb*.
