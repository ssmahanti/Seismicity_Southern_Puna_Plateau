# Start of the makefile
# Defining variables
objects = vrefmod.o nolet.o anom_3D_xyz_lin_v.o read_3D_mod_v.o velocity.o vert_anom.o read_vref.o read_ini_model.o sfdec.o invers.o 
tmp_src = vrefmod.f90 nolet.f90 anom_3D_xyz_lin_v.f90 read_3D_mod_v.f90 velocity.f90 vert_anom.f90 read_vref.f90 read_ini_model.f90 sfdec.f90
f90comp = gfortran
switch = -O3
executable = invers.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o $(executable) $(switch) $(objects)
	rm $(objects)
vrefmod.f90 :
	cp ../../subr/rays_locate/vrefmod.f90 vrefmod.f90
read_vref.f90 :
	cp ../../subr/rays_locate/read_vref.f90 read_vref.f90
nolet.f90 :
	cp ../../subr/invers/nolet.f90 nolet.f90
read_ini_model.f90 :
	cp ../../subr/synth/read_ini_model.f90 read_ini_model.f90
vert_anom.f90 :
	cp ../../subr/synth/vert_anom.f90 vert_anom.f90
sfdec.f90 :
	cp ../../subr/convers/sfdec.f90 sfdec.f90
velocity.f90 :
	cp ../../subr/3D_model/velocity.f90 velocity.f90
read_3D_mod_v.f90 :
	cp ../../subr/3D_model/read_3D_mod_v.f90 read_3D_mod_v.f90
anom_3D_xyz_lin_v.f90 :
	cp ../../subr/3D_model/anom_3D_xyz_lin_v.f90 anom_3D_xyz_lin_v.f90	
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm $(executable)
# End of the makefile
