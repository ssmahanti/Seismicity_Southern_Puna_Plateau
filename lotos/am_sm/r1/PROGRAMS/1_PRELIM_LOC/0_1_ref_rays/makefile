# Start of the makefile
# Defining variables
objects = ray_lay.o reftrace.o vrefmod.o refrays.o read_vref.o
tmp_src = ray_lay.f90 reftrace.f90 vrefmod.f90 read_vref.f90
f90comp = gfortran
switch = -O3
# Makefile
all : refrays.exe
refrays.exe : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o refrays.exe $(switch) $(objects)
	rm $(objects)
ray_lay.f90 : 
	cp ../../subr/rays_locate/ray_lay.f90 ray_lay.f90
reftrace.f90 :
	cp ../../subr/rays_locate/reftrace.f90 reftrace.f90
vrefmod.f90 :
	cp ../../subr/rays_locate/vrefmod.f90 vrefmod.f90  	
read_vref.f90 :
	cp ../../subr/rays_locate/read_vref.f90 read_vref.f90  	
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm refrays.exe
# End of the makefile
