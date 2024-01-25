SUBDIRS= 0_START/check_data 0_START/START \
	1_PRELIM_LOC/0_1_ref_rays 1_PRELIM_LOC/0_2_loc_event \
	2_INVERS_3D/1_locate 2_INVERS_3D/2n_ray_density \
	2_INVERS_3D/3n_grid 2_INVERS_3D/4n_tetrad \
	2_INVERS_3D/5n_sosedi 2_INVERS_3D/6n_matr 2_INVERS_3D/7n_invers \
	2_INVERS_3D/8n_3D_model 3_VISUAL/variance_reduction \
	3_VISUAL/_vis_n_hor_result 3_VISUAL/_vis_n_ver_result \
	3_VISUAL/_vis_ray_path 4_CREATE_SYN_DATA/a_set_syn_hor \
	4_CREATE_SYN_DATA/a_set_syn_ver 4_CREATE_SYN_DATA/b_synth_times

MAKE = make
#MFLAGS = 

all: 
	@echo "Making all in `$(PWD)`"
	@for i in $(SUBDIRS); do             \
                echo "  Entering subdirectory $$i";             \
                ( cd $$i; $(MAKE) $(MFLAGS) all );              \
                if test $$? != 0 ; then exit 1; fi ;    \
                echo " ";	\
	done

clean: 
	@echo "Making all in `$(PWD)`"
	@for i in $(SUBDIRS); do             \
                echo "  Entering subdirectory $$i";             \
                ( cd $$i; $(MAKE) $(MFLAGS) clean );              \
                if test $$? != 0 ; then exit 1; fi ;    \
                echo " ";	\
	done

