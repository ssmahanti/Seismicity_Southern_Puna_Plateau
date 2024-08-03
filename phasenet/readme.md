# Steps to Run PhaseNet for the Southern Puna Dataset:

## 1. Downloading Data:

1. Download data from GEOFON DMC for the stations from 2B network as 24 hours daily traces.
2. Download data from IRISDMC for the stations from X6 network as 24 hours daily traces.
3. Organise the data in daywise folders using *data_org.sh* script.
4. Run *trace_check.py* to check the traces to verify if all the traces run from T00:00:00 to T23:59:59.990000 

## 2. Run PhaseNet:

1. Download PhaseNet package
2. Based on the sampling rate of data adjust (for version= 0.1.0):
	a. change the sampling rate in [PhaseNet folder]/main/phasenet/datareader.py
	b. change dt=1/sampling_rate in [PhaseNet folder]/main/phasenet/visualization.py

3. Run *./run_phasenet.sh* for IRIS and GEOFON data separately by editing the shell script accordingly. The results are saved in results_gfz or results_iris 	folder in day-wise folders.

4. Be careful of the data starttime (need to be T00:00:00) and sampling rate while running PhaseNet.
