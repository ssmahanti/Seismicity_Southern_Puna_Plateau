# Steps to perform for Focal Mechanism Analysis:

The FOCMEC package from the following reference is used to obtain the focal mechanisms.

Snoke, J. A. (2003). 85.12 FOCMEC: FOCal MEChanism determinations (pp. 1629–1630). https://doi.org/10.1016/S0074-6142(03)80291-7

## 1. Prerequisite:

1. Waveform data for the event in MSEED format.
2. Phase File with all the arrivals.


## 2. Prepare Input Files:

The jupyter notebook *./notebooks/focmec_input_prep_combine* is used to prepare the input files.

1. Select the event from the HypoDD catalog and paste it to the *./input_prep/inputs/target_event.txt*.
2. Extract the phases detected for the event from the combined phase file of all the events.
3. Calculate azimuth and take-off angle for the rays to the station using *Obspy* and *TauP* and save to *./input_prep/prelims_v5/focmec_prelim_$eventid_p.txt*.
4. Initiate a polarity file for the phases: *./input_prep/polarity_v5/$eventid_p.txt*
5. Combine these two files to create the *FOCMEC* program input file: *./input_prep/focmec_input/puna_$eventid_p.inp*.
6. Use the template for focmec_runs and create a new folder for each event and copy the input file to the folder.

## 3. Pick Polarity for the events:

1. Select a 5 second window around the arrival at each station and update the polarity in the input file.

## 4. Running FOCMEC:

1. Run *./focmec_runs/$eventid/rfocmec_uw.run* to estimate the focal mechanisms.
2. Adjust the allowed polarity errors and number of solutions for each event.
3. Run *./focmec_runs/$eventid/rfocmec_rw.run* to estimate the focal mechanisms with relative weighting.

