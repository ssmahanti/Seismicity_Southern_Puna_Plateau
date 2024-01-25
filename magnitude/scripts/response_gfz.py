#Download response information from GEOFON DMC for 2B stations.

from pyrocko.client import fdsn
from pyrocko import util, io, trace, model
from pyrocko.io import quakeml

tmin = util.stt('2008-01-01 00:00:00.000')
tmax = util.stt('2009-09-30 23:59:59.000')

# request events at IRIS for the given time span

fn=open("2B_stations.txt",'r')
stnlist=fn.readlines()

for stn1 in stnlist:
    stn=stn1.rstrip()

# download
    selection = [('2B', stn , '*', '*N', tmin, tmax)]
 
# request meta data
    request_response = fdsn.station(
        site='geofon', selection=selection, level='response')

# save the response in YAML and StationXML format
    request_response.dump(filename='resp.2B.%s.HHN.yaml'%stn)
    request_response.dump_xml(filename='resp.2B.%s.HHN.xml'%stn)
