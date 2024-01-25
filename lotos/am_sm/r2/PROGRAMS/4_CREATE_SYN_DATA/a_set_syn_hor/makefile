# Start of the makefile
# Defining variables
objects = decsf.o dv_board.o hor_anom.o int_best.o prep_board_dv.o read_hor_an.o read_vert_an.o read_vert_brd.o sfdec.o vert_anom.o vert_brd.o vrefmod.o z_lim.o read_topo.o read_vref.o h_lim.o read_anom.o anomaly.o create.o 
tmp_src = decsf.f90 dv_board.f90 hor_anom.f90 int_best.f90 prep_board_dv.f90 read_hor_an.f90 read_vert_an.f90 read_vert_brd.f90 sfdec.f90 vert_anom.f90 vert_brd.f90 vrefmod.f90 z_lim.f90 read_topo.f90 read_vref.f90 h_lim.f90 read_anom.f90 anomaly.f90 
f90comp = gfortran
switch = -O3
executable = create.exe
# Makefile
all : $(executable)
$(executable) : $(objects)
	rm $(tmp_src)	
	$(f90comp) -o $(executable) $(switch) $(objects)
	rm $(objects)
decsf.f90 :
	cp ../../subr/convers/decsf.f90 decsf.f90
read_anom.f90 :
	cp ../../subr/synth/read_anom.f90 read_anom.f90
anomaly.f90 :
	cp ../../subr/synth/anomaly.f90 anomaly.f90
dv_board.f90 :
	cp ../../subr/synth/dv_board.f90 dv_board.f90
hor_anom.f90 :
	cp ../../subr/synth/hor_anom.f90 hor_anom.f90
int_best.f90 :	
	cp ../../subr/other/int_best.f90 int_best.f90
prep_board_dv.f90 :
	cp ../../subr/synth/prep_board_dv.f90 prep_board_dv.f90
read_hor_an.f90 :
	cp ../../subr/synth/read_hor_an.f90 read_hor_an.f90
read_vert_an.f90 :
	cp ../../subr/synth/read_vert_an.f90 read_vert_an.f90
read_vert_brd.f90 :
	cp ../../subr/synth/read_vert_brd.f90 read_vert_brd.f90
sfdec.f90 :	
	cp ../../subr/convers/sfdec.f90 sfdec.f90
vert_anom.f90 :
	cp ../../subr/synth/vert_anom.f90 vert_anom.f90
vert_brd.f90 :	
	cp ../../subr/synth/vert_brd.f90 vert_brd.f90	
z_lim.f90 :	
	cp ../../subr/rays_locate/z_lim.f90 z_lim.f90
vrefmod.f90 :	
	cp ../../subr/synth/vrefmod.f90 vrefmod.f90
read_vref.f90 :
	cp ../../subr/synth/read_vref.f90 read_vref.f90
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
	rm $(executable)
# End of the makefile
