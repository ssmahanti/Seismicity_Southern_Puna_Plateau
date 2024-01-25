!USE DFPORT
character*8 ar,md,line
character*1 it
common/refmod/nref,zref(600),vref(600,2)


open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the area
close(1)


open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=563)line
	if(line.eq.'GENERAL ') goto 564
end do
563 continue
write(*,*)' cannot find GENERAL INFORMATION in MAJOR_PARAM.DAT!!!'
pause
564 continue
read(1,*)k_re1_syn2
close(1)




open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=553)line
	if(line.eq.'1D MODEL') goto 554
end do
553 continue
write(*,*)' cannot find AREA CENTER in MAJOR_PARAM.DAT!!!'
pause

554 read(1,*)niter
close(1)
write(*,*)' number of iterations:',niter


key_preview=0
open(1,file='../../../preview_key.txt')
read(1,*,end=771)key_preview
771 close(1)

if(key_preview.eq.0) stop

!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************


i=system('mkdir ..\..\..\PICS\'//ar//'\'//md)
open(1,file='../../../DATA/'//ar//'/config.txt')

do i=1,7
	read(1,*)
end do
read(1,*) npix_x,npix_y
read(1,*)x_min,x_max
read(1,*)y_min,y_max
read(1,*)tick_x,tick_y
close(1)

i=system('copy ..\..\..\COMMON\visual_exe\visual.exe layers.exe')

open(14,file='config.txt')
write(14,*)npix_x,npix_y
write(14,*)'_______ Size of the picture in pixels (nx,ny)'
write(14,*)x_min,x_max
write(14,*)'_______ Physical coordinates along X (xmin,xmax)'
write(14,*)y_min,y_max
write(14,*)'_______ Physical coordinates along Y (ymin,ymax)'
write(14,*)tick_x,tick_y
write(14,*)'_______ Spacing of ticks on axes (dx,dy)'
write(14,51)ar,md
51 format('..\..\..\PICS\',a8,'\',a8,'\1D_mod.png')
write(14,*)'_______ Path of the output picture'
if(k_re1_syn2.eq.2) then
	write(14,3332)	
	3332 format(' 1D models: green - true, grey - starting, red - final, thin - intermediate')
else
	write(14,3331)	
	3331 format(' 1D models: grey - starting, red - final, thin - intermediate')
end if
write(14,*)'_______ Title of the plot on the upper axe'
write(14,*)	1
write(14,*)'_______ Number of layers'

59 format('********************************************')

if(k_re1_syn2.eq.2) then

    open(1,file='../../../DATA/'//ar//'/'//md//'/ref_syn.dat')
    read(1,*,end=81)vpvs
    iref=0
    82 continue
        read(1,*,end=81)z,vp,vs
        iref=iref+1
        zref(iref)=z
        vref(iref,1)=vp
        if(vpvs.lt.0.000001) then
            vref(iref,2)=vs
        else
            vref(iref,2)=vref(iref,1)/vpvs
        end if
        goto 82
    81 close(1)
    nref=iref
    write(*,*)' nref=',nref
    open(11,file='../../../TMP_files/1D_mod/ref_true.bln')
    write(11,*)nref
    do i=1,nref
        write(11,*)vref(i,1),-zref(i)
    end do
    write(11,*)nref
    do i=1,nref
        write(11,*)vref(i,2),-zref(i)
    end do
    close(11)



	write(14,59)
	write(14,*)	2
	write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
	write(14,57)
	57 format('..\..\..\TMP_files\1D_mod\ref_true.bln')
	write(14,*)'_______ Location of the BLN file'
	write(14,*)	4
	write(14,*)'_______ Thickness of line in pixels'
	write(14,*)	0,250,0
	write(14,*)'_______ RGB color'

end if

write(14,59)
write(14,*)	2
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,54)
54 format('..\..\..\TMP_files\1D_mod\ref_start.bln')
write(14,*)'_______ Location of the BLN file'
write(14,*)	4
write(14,*)'_______ Thickness of line in pixels'
write(14,*)	130,130,130
write(14,*)'_______ RGB color'

do iter=1,niter	
	write(it,'(i1)')iter
	write(14,59)
	write(14,*)	2
	write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
	write(14,56)it
	56 format('..\..\..\TMP_files\1D_mod\ref',a1,'.bln')
	write(14,*)'_______ Location of the BLN file'
	write(14,*)	1
	write(14,*)'_______ Thickness of line in pixels'
	write(14,*)	0,0,0
	write(14,*)'_______ RGB color'
end do

write(14,59)
write(14,*)	2
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,55)
55 format('..\..\..\TMP_files\1D_mod\ref_final.bln')
write(14,*)'_______ Location of the BLN file'
write(14,*)	4
write(14,*)'_______ Thickness of line in pixels'
write(14,*)	250,0,0
write(14,*)'_______ RGB color'

close(14)


i=system('layers.exe')





stop
end