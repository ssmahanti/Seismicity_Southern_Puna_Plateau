# Start of the makefile
# Defining variables
objects = vrefmod.o ray_lay.o dispers.o refmod_all.o goal_new.o reftrace.o decsf.o h_lim.o sfdec.o z_lim.o prepare_ref.o read_z_limit.o read_topo.o
tmp_src =  vrefmod.f90 ray_lay.f90  dispers.f90 refmod_all.f90 goal_new.f90 reftrace.f90 decsf.f90 h_lim.f90 sfdec.f90 z_lim.f90 prepare_ref.f90 read_z_limit.f90 read_topo.f90
f90comp = gfortran
switch = -O3
executable = locate.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	$(f90comp)  locate.f90 $(objects) -o  $(executable)
decsf.f90 :
	cp ../../subr/convers/decsf.f90 decsf.f90
h_lim.f90 :	
	cp ../../subr/rays_locate/h_lim.f90 h_lim.f90
sfdec.f90 :
	cp ../../subr/convers/sfdec.f90 sfdec.f90
z_lim.f90 :
	cp ../../subr/rays_locate/z_lim.f90 z_lim.f90
dispers.f90 :	
	cp ../../subr/rays_locate/dispers.f90 dispers.f90
refmod_all.f90 :	
	cp ../../subr/rays_locate/refmod_all.f90 refmod_all.f90
goal_new.f90 :
	cp ../../subr/rays_locate/goal_new.f90 goal_new.f90			
vrefmod.f90 :
	cp ../../subr/rays_locate/vrefmod.f90 vrefmod.f90
ray_lay.f90 :
	cp ../../subr/rays_locate/ray_lay.f90 ray_lay.f90
prepare_ref.f90 :
	cp ../../subr/rays_locate/prepare_ref.f90 prepare_ref.f90
reftrace.f90 :
	cp ../../subr/rays_locate/reftrace.f90 reftrace.f90
read_z_limit.f90 :
	cp ../../subr/rays_locate/read_z_limit.f90 read_z_limit.f90
read_topo.f90 :
	cp ../../subr/rays_locate/read_topo.f90 read_topo.f90
%.o: %.f90
	$(f90comp) -c $(switch) $<
