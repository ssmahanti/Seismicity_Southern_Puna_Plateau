# Start of the makefile
# Defining variables
objects = decsf.o Tetrad.o 
tmp_src = decsf.f90
f90comp = gfortran
switch = -O3
executable = Tetrad.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o $(executable) $(switch) $(objects)
	rm $(objects)
decsf.f90 :
	cp ../../subr/convers/decsf.f90 decsf.f90
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean: 
	rm $(objects)
	rm $(tmp_src)
	rm $(executable)
# End of the makefile
