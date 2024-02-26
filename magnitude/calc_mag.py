#Script modified from LOC-FLOW
#calculate local magnitude for earthquakes located by REAL associator.. We need the phase files from REAL and sacfiles of actual data
#The maginput.sh script  creates the magcalc.txt file for each day.

import obspy
import os
import math
from math import log10,sqrt
import numpy as np
from statistics import mean
from obspy import read,UTCDateTime
from obspy.geodetics import locations2degrees
from obspy import read, read_inventory


inp=input()
year=int(inp.split('.')[0])
mon=int(inp.split('.')[1])
day=int(inp.split('.')[2])

mon2=str(mon)
day2=str(day)
mon1=str(mon).zfill(2)
day1=str(day).zfill(2)

#Edit the path as required
#sacfiles are required for running. Currently those are kept in core2 server /core2/sankha/puna/data
ddirwaveform_iris = './data/saciris/2009/'+str(year)+'.'+str(mon2)+'.'+str(day2)+'/merged'
ddirwaveform_gfz = './/data/sacgfz/2009/'+str(year)+'.'+str(mon2)+'.'+str(day2)+'/merged'
stationdir = '../station/spuna_stations.txt'
phasedir = '../real/result_real_puna/'+str(year)+mon1+day1+'/magcalc.txt'
catmag = './puna_mag.txt'
g = open(catmag,'w')


#Wood-Anderson response that will be simulated
paz_wa = {'poles': [-5.49779 + 5.60886j, -5.49779 - 5.60886j],
                'zeros': [0 + 0j, 0j], 'gain': 1.0, 'sensitivity': 2080}   #Extra 0 is added to convert to dosplacement

def response(resppath):
    fi=open(resppath)
    line=fi.readlines()
    zeros=[]
    poles=[]
    sens=float((line[21].split(':')[1]).split()[0])
    ao=float((line[22].split(':')[1]))
    nzs=int(line[24].split()[1])
    nps=int(line[24+nzs+1].split()[1])
    for qq in range(nzs):
        zero_r=float(line[25+qq].split()[0])
        zero_c=float(line[25+qq].split()[1])
        zero=complex(zero_r,zero_c)
        zeros.append(zero)
    for qq in range(nps):
        pole_r=float(line[25+nzs+1+qq].split()[0])
        pole_c=float(line[25+nzs+1+qq].split()[1])
        pole=complex(pole_r,pole_c)
        poles.append(pole)
    paz_w = {'poles': poles, 'zeros': zeros, 'gain': ao, 'sensitivity': sens}
    return paz_w


#paz_wa={'poles': [(-0.03701+5j), (-0.03701+0.03701j), (-1131-0.03701j), (-1005+0j), (-502.7+0j)], 'zeros': [0+0j, 0+0j, 0+0j], 'gain': 571400000.0, 'sensitivity': 946633000.0}
i=0
mags = []
with open(phasedir) as p:
    for lines in p:
        string = lines.split()[0]
        if string == "EOF":
                net_mag = np.median(mags)
                net_var = np.var(mags)
 
                g.write('{} {} {} {} {} {} {} {} {} {} {} {}\n'.format(int(num), year0, mon0, day0, hour0, minute0, tmp0, lat0, lon0, dep0, round(float(net_mag),2),round(float(net_var),2)))
                
                print('{} {} {} {} {} {} {} {} {} {} {} {}\n'.format(int(num), year0, mon0, day0, hour0, minute0, tmp0, lat0, lon0, dep0, round(float(net_mag),2),round(float(net_var),2)))
                
        elif string == '#':
            if i>0:
                net_mag = np.median(mags)
                net_var = np.var(mags)
  #              print(mags)
                g.write('{} {} {} {} {} {} {} {} {} {} {} {}\n'.format(int(num), year0, mon0, day0, hour0, minute0, tmp0, lat0, lon0, dep0, round(float(net_mag),2),round(float(net_var),2)))
       #         print(mags)
                print('{} {} {} {} {} {} {} {} {} {} {} {}\n'.format(int(num), year0, mon0, day0, hour0, minute0, tmp0, lat0, lon0, dep0, round(float(net_mag),2),round(float(net_var),2)))
                mags = []
            
            string, year, mon, day, hour, minute, tmp, lat, lon, dep, mag0, jk1, jk2, jk3, num = lines.split()
            sec,msec=tmp.split('.')
            date = year+mon+day           
            year0 = year
            mon0 = mon
            day0 = day
            hour0 = hour
            minute0 = minute
            tmp0 = tmp
            lat0 = lat
            lon0 = lon
            dep0 = dep
            i = 0
        else:
            net0, station, tpick, tweight, phase = lines.split()

            with open(stationdir, "r") as f:
                for stations in f:
                    stlo, stla, net, sta, chan, ele = stations.split()
                    dist0 = 111.19*locations2degrees(float(lat), float(lon), float(stla), float(stlo))
                    if net0==net and sta==station:
                        dist = math.sqrt(dist0**2+float(dep)**2)
                        if phase == 'P':
                            # cover the P phase and 3 sec after the S phase, just an example, change as needed.
                            tb = UTCDateTime(int(year),int( mon), int(day), int(hour), int(minute), int(sec), int(msec))+ float(tpick) - 2
                            te = tb + 0.73*(dist/6.0) + 3 #0.73*dist/6.0 is approximated to ts - tp
                        elif phase == 'S':
                            tb = UTCDateTime(int(year),int( mon), int(day), int(hour), int(minute), int(sec), int(msec)) + float(tpick) - 0.73*(dist/6.0) - 2
                            te = tb + 0.732*(dist/6.0) + 3
                        chann = chan[:2]+"N"
                        chane = chan[:2]+"E"

                        ##########################################################################
                        #Response removal for IRIS Data with sac polezero files

                        if net0=="X6":
                            wavee = ddirwaveform_iris+'/'+net+'.'+station+'..'+chane+'.M.2009.'+mon2+'.'+day2+'.SAC'                      
                            waven = ddirwaveform_iris+'/'+net+'.'+station+'..'+chann+'.M.2009.'+mon2+'.'+day2+'.SAC'
                            tre = read(wavee,starttime=tb,endtime=te)
                            trn = read(waven,starttime=tb,endtime=te)
                
                            respdir='./data/responses/resp_x6'            
                            resppathE=respdir+'/'+'SACPZ.X6.'+station+'.BHE'
                            resppathN=respdir+'/'+'SACPZ.X6.'+station+'.BHN'
                            paz_we=response(resppathE)
                            paz_wn=response(resppathN)                       

                            tre.simulate(paz_remove = paz_we, paz_simulate = paz_wa)
                            trn.simulate(paz_remove = paz_wn, paz_simulate = paz_wa)

                         # Response removal for GFZ Data with response files in XML format   
                        else:
                            wavee = ddirwaveform_gfz+'/'+net+'.'+station+'..'+chane+'.D.2009.'+mon2+'.'+day2+'.SAC'
                            waven = ddirwaveform_gfz+'/'+net+'.'+station+'..'+chann+'.D.2009.'+mon2+'.'+day2+'.SAC'
                            tre = read(wavee,starttime=tb,endtime=te)
                            trn = read(waven,starttime=tb,endtime=te)

                            respdir='./data/responses/resp_2B'
                            resppathE=respdir+'/'+'resp.2B.'+station+'.HHE.xml'
                            resppathN=respdir+'/'+'resp.2B.'+station+'.HHN.xml'                           
                            inv_e = read_inventory(resppathE)
                            inv_n = read_inventory(resppathN)

                            tre.remove_response(inventory=inv_e, output='DISP')
                            tre.simulate(paz_remove=None, paz_simulate=paz_wa)
                            trn.remove_response(inventory=inv_n, output='DISP')
                            trn.simulate(paz_remove=None, paz_simulate=paz_wa)


                        datatre = tre[0].data
                        datatrn = trn[0].data
                        #1000 is from meter to millimeter (mm) see Hutton and Boore (1987)
                        amp = (np.max(np.abs(datatre)) + np.max(np.abs(datatrn)))/2*1000
                        i = 1
                        if amp==0:
                            amp=0.0000001
                        #see Hutton and Boore (1987)
                        ml = log10(amp) + 1.110*log10(dist/100) + 0.00189*(dist-100)+3.0
                        #Just an example! please change into your magnitude formula.
                        mags.append(round(ml,2))
                        
                        break
