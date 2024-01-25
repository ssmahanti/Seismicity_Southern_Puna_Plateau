# Start of the makefile
# Defining variables
objects = decsf.o int_best.o sfdec.o paths.o
tmp_src =  decsf.f90 int_best.f90 sfdec.f90
f90comp = gfortran
switch = -O3
executable = paths.exe
# Makefile
all : $(executable)
$(executable)  : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o $(executable) $(switch) $(objects)
	rm $(objects)
decsf.f90 :	
	cp ../../subr/convers/decsf.f90 decsf.f90
int_best.f90 :	
	cp ../../subr/other/int_best.f90 int_best.f90
sfdec.f90 :	
	cp ../../subr/convers/sfdec.f90 sfdec.f90
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm $(executable) 
# End of the makefile
