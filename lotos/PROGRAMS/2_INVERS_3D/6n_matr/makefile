# Start of the makefile
# Defining variables
objects = vrefmod.o read_vref.o read_3D_mod_v.o velocity.o anom_3D_xyz_lin_v.o vert_anom.o matr.o 
tmp_src = vrefmod.f90 read_vref.f90 read_3D_mod_v.f90 velocity.f90 anom_3D_xyz_lin_v.f90 vert_anom.f90
f90comp = gfortran
switch = -O3
executable = matr.exe
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
read_3D_mod_v.f90 :	
	cp ../../subr/3D_model/read_3D_mod_v.f90 read_3D_mod_v.f90
velocity.f90 :	
	cp ../../subr/3D_model/velocity.f90 velocity.f90
anom_3D_xyz_lin_v.f90 :	
	cp ../../subr/3D_model/anom_3D_xyz_lin_v.f90 anom_3D_xyz_lin_v.f90
vert_anom.f90 :	
	cp ../../subr/synth/vert_anom.f90 vert_anom.f90
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm $(executable)
# End of the makefile
