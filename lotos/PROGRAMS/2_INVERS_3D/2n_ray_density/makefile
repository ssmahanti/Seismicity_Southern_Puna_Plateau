# Start of the makefile
# Defining variables
objects = int_best.o plotray.o 
tmp_src = int_best.f90
f90comp = gfortran
switch = -O3
executable = plotray.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o $(executable) $(switch) $(objects)
	rm $(objects)
int_best.f90 :
	cp ../../subr/other/int_best.f90 int_best.f90	
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm $(executable)
# End of the makefile
