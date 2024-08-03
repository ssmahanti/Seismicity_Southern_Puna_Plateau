#This script extracts the P and T axis directions from focal mechanisms:

from pyrocko import moment_tensor as pmt
import numpy as num
from obspy.imaging.beachball import beachball
import pandas as pd

r2d = 180. / num.pi #radian to degrees

df = pd.read_csv("focmec_output.txt",sep='\s+') #focal mechanism file
fo = open('focmec_axes_v2.dat','w') #output file

for i in range(len(df['id'])):
	strike = df['Strike'][i]
	dip = df['Dip'][i]
	rake = df['Rake'][i]
	magnitude = df['Magnitude'][i]  # Magnitude of the earthquake
	print(strike,dip,rake,magnitude)
	m0 = pmt.magnitude_to_moment(magnitude)  # convert the mag to moment
	mt = pmt.MomentTensor(strike=strike, dip=dip, rake=rake, scalar_moment=m0)

	# P-axis normal vector in north-east-down coordinates
	p_ned = mt.p_axis()
	p_azimuth = num.arctan2(p_ned.item(0,1), p_ned.item(0,0)) * r2d
	p_dip = num.arcsin(p_ned.item(0,2)) * r2d

	# T-axis normal vector in north-east-down coordinates
	t_ned = mt.t_axis()
	t_azimuth = num.arctan2(t_ned.item(0,1), t_ned.item(0,0)) * r2d
	t_dip = num.arcsin(t_ned.item(0,2)) * r2d

	print(df['id'][i],df['Longitude'][i],df['Latitude'][i],df['Depth'][i],strike,dip,rake,magnitude,round(p_azimuth,2), round(p_dip,2),round(t_azimuth,2),round(t_dip,2),df['Location'][i],file=fo)
