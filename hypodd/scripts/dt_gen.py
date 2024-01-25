import random
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
df2=pd.read_csv("../hypodd_puna_v5.reloc",sep="\s+",header=None)

fi = open("../dt.ct",'r')
fo=open("../resampling/dt_noisy.ct",'w')
data = fi.readlines()
for line in data:
    if line.split()[0]!="#":
        err=random.choice([-1, 1]) * random.choice(df2[22])

        dt1=(float(line.split()[1])+err)
        dt2=float(line.split()[2])
        print(line.split()[0]," ","%6.3f"%dt1,"","%6.3f"%dt2,line.split()[3],line.split()[4],file=fo)
    else:
        print(line.strip(),file=fo)    