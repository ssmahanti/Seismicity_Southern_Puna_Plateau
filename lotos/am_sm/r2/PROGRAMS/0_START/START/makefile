# Start of the makefile
# Defining variables
objects = visual_srces_stat.o start.o
tmp_src = visual_srces_stat.f90  
f90comp = gfortran
switch = -O3
executable = start.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o $(executable) $(switch) $(objects)
	rm $(objects)
visual_srces_stat.f90 :
	cp ../../subr/visual/visual_srces_stat.f90 visual_srces_stat.f90
%.o: %.f90
	$(f90comp) -c $(switch) $<
# Cleaning everything
clean:
	rm $(executable) 
	rm $(objects)
	rm $(tmp_src)
# End of the makefile
