# Magnitude Estimation workflow:


## 1. Input Preperation:

1. Run *./scripts/mag_input.sh* to create the phase files (*magcalc.txt*) in the REAL result folders.
2. Run *create_sac.sh* to obtain SAC files from the mseed files.
3. Run *./scripts/sac_merge.sh* to merge SAC files into one trace per day.
4. Scripts to download the response files are also provided.


## 2. Calculate Magnitude:

1. The *calc_mag.py* script is obtained and modified from https://github.com/Dal-mzhang/REAL.git
2. Modify the paths in *calc_mag.py* as required.
3. Run *calc_mag.sh* to calculate the magnitude. It requires the actual SAC data and phase files from REAL associator.
4. Calculated magnitudes are listed in *puna_mag_real_v5.txt*

## 3. Make Catalog:

1. Run *selectevent.py* to extract the events of velest or hypoDD catalog.

## 4. Analysis:

1. Go through the jupyter notebook *magnitude_analysis.ipynb* to fit the magnitude to Gutenberg-Richter law and obtain b-value.