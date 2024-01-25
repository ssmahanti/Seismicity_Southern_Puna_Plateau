
fi=open('SACPZ.X6.BB09.BHZ')
line=fi.readlines()

zeros=[]
poles=[]

sens=float((line[21].split(':')[1]).split()[0])
gain=float((line[22].split(':')[1]))
nz=int(line[24].split()[1])
np=int(line[24+nz+1].split()[1])

for i in range(nz):
	zero_r=float(line[25+i].split()[0])
	zero_c=float(line[25+i].split()[1])
	zero=complex(zero_r,zero_c)
	print(zero)
	zeros.append(zero)

for i in range(np):
	print(line[25+nz+1+i].split())
	pole_r=float(line[25+nz+1+i].split()[0])
	pole_c=float(line[25+nz+1+i].split()[1])
#	print(pole_r,pole_c)
	pole=complex(pole_r,pole_c)
	poles.append(pole)

print(poles)