# Start of the makefile
# Defining variables
objects = vrefmod.o ray_lay.o reftrace.o
tmp_src =  vrefmod.f90 ray_lay.f90 reftrace.f90
f90comp = gfortran
switch = -O3
executable = refrays.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	$(f90comp) -o  $(executable) $(switch) $(objects)
vrefmod.f90 :
	cp ../../subr/rays_locate/vrefmod.f90 vrefmod.f90
ray_lay.f90 :
	cp ../../subr/rays_locate/ray_lay.f90 ray_lay.f90
reftrace.f90 :
	cp ../../subr/rays_locate/reftrace.f90 reftrace.f90
%.o: %.f90
	$(f90comp) -c $(switch) $<
