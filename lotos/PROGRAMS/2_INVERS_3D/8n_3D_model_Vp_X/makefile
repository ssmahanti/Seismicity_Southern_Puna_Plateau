# Start of the makefile
# Defining variables
objects = vrefmod.o prepare_model_v.o prepare_model_x.o kram3.o dv_1_gr_xyz_v.o read_vref.o mod_3D.o
tmp_src = vrefmod.f90 prepare_model_x.f90 prepare_model_v.f90 kram3.f90 dv_1_gr_xyz_v.f90 read_vref.f90 
f90comp = gfortran
switch = -O3
executable = mod_3D.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o $(executable) $(switch) $(objects)
	rm $(objects)
read_vref.f90 :
	cp ../../subr/rays_locate/read_vref.f90 read_vref.f90
vrefmod.f90 :
	cp ../../subr/rays_locate/vrefmod.f90 vrefmod.f90
prepare_model_x.f90 :
	cp ../../subr/visual/prepare_model_x.f90 prepare_model_x.f90
prepare_model_v.f90 :
	cp ../../subr/visual/prepare_model_v.f90 prepare_model_v.f90
kram3.f90 :
	cp ../../subr/invers/kram3.f90 kram3.f90
dv_1_gr_xyz_v.f90 :
	cp ../../subr/visual/dv_1_gr_xyz_v.f90 dv_1_gr_xyz_v.f90	
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm $(executable)
# End of the makefile
