# Start of the makefile
# Defining variables
objects = dv_1_grid_v.o prepare_model_v.o read_ini_model.o vert_anom.o decsf.o kram3.o sfdec.o vrefmod.o read_vref.o read_topo.o h_lim.o visual.o
tmp_src =  dv_1_grid_v.f90 prepare_model_v.f90 read_ini_model.f90 vert_anom.f90 decsf.f90 kram3.f90 sfdec.f90 vrefmod.f90 read_vref.f90 read_topo.f90 h_lim.f90
f90comp = gfortran
switch = -O3
# Makefile
all : visual.exe
visual.exe : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o visual.exe $(switch) $(objects)
	rm $(objects)
dv_1_grid_v.f90 :
	cp ../../subr/visual/dv_1_grid_v.f90 dv_1_grid_v.f90
prepare_model_v.f90 :	
	cp ../../subr/visual/prepare_model_v.f90 prepare_model_v.f90
read_ini_model.f90 :	
	cp ../../subr/synth/read_ini_model.f90 read_ini_model.f90
vert_anom.f90 :	
	cp ../../subr/synth/vert_anom.f90 vert_anom.f90
decsf.f90 :	
	cp ../../subr/convers/decsf.f90 decsf.f90
kram3.f90 :	
	cp ../../subr/invers/kram3.f90 kram3.f90
sfdec.f90 :	
	cp ../../subr/convers/sfdec.f90 sfdec.f90
vrefmod.f90 :	
	cp ../../subr/3D_model/vrefmod.f90 vrefmod.f90
read_vref.f90 :
	cp ../../subr/rays_locate/read_vref.f90 read_vref.f90
read_topo.f90 :	
	cp ../../subr/rays_locate/read_topo.f90 read_topo.f90
h_lim.f90 :	
	cp ../../subr/rays_locate/h_lim.f90 h_lim.f90
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm visual.exe
# End of the makefile
