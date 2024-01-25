# Steps to Run PhaseNet for the Southern Puna Dataset:

## Required Python Modules:

Obspy, Pyrocko

## 1. Downloading Data:

1. Run *geofon_download.py* to download data from GEOFON DMC using the 2B station list.
2. Run *geofon_data_org.sh* to organise the data in day-wise folders.
3. Use Breqfast request service from IRISDMC to download the data from X6 stations.
4. Run *iris_download.py* to extract daywise mseed files and organise in day-wise folders.
5. Run *trace_check.py* to check the traces to verify if all the traces run from T00:00:00 to T23:59:59.990000 

## 2. Run PhaseNet:

1. Based on the sampling rate of data adjust:
	a. change the sampling rate in ./main/phasenet/datareader.py
	b. change dt=1/sampling_rate in ./main/phasenet/visualization.py

2. Run *./run_phasenet.sh* for IRIS and GEOFON data separately by editing the shell script accordingly. The results are saved in results_gfz or results_iris folder in day-wise folders.

3. Be careful of the data starttime (need to be T00:00:00) and sampling rate while running PhaseNet.
