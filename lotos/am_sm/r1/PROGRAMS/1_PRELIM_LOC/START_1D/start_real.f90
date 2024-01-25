!USE DFPORT
character*8 ar,md,line
character*1 it
common/refmod/nrefmod,hmod(600),vmodp(600),vmods(600)


open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the area
close(1)

i=system('mkdir ../../../TMP_files/1D_mod')
i=system('cp ../../../DATA/'//ar//'/'//md//'/ref_start.dat &
    ../../../DATA/'//ar//'/'//md//'/data/ref_start.dat')

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

i=system('../../1_PRELIM_LOC/1_select/select.exe')

!******************************************************************
	
do iter=1,niter	

	write(it,'(i1)')iter

	open(11,file='../../../model.dat')
	write(11,'(a8)')ar		
	write(11,'(a8)')md		
	write(11,'(i1)')iter		
	close(11)

	write(*,*)'	 ****************************************************'
	write(*,*)'	 Reference table:'
	i=system('../../1_PRELIM_LOC/2_reftable/refrays.exe')

	write(*,*)'	 ****************************************************'
	write(*,*)'	 Source location:'
	i=system('../../1_PRELIM_LOC/3_locate/locate.exe')

	write(*,*)'	 ****************************************************'
	write(*,*)'	 Matrix calculation:'
	i=system('../../1_PRELIM_LOC/4_matr/matr.exe')

	write(*,*)'	 ****************************************************'
	write(*,*)'	 Inversion:'
	i=system('../../1_PRELIM_LOC/5_invers/invers.exe')

end do ! Different iterations

i=system('mkdir ../../../PICS/'//ar//'/'//md)

dmin=99999
open(1,file='../../../DATA/'//ar//'/'//md//'/data/1d_info.dat')
open(11,file='../../../TMP_files/1D_mod/1d_info.dat')
do i=1,niter
    read(1,*)ittt,ntot,dold,dnew,perc
    write(11,23)ittt,ntot,dold,dnew,perc
23  format(' iteration:',i2,' nrays=',i6,' old RMS=',f8.4,' new RMS=',f8.4,' reduction:',f8.2)
    if(dnew.lt.dmin) then
        imin=i
        dmin=dnew
    end if
end do
close(1)

write(*,*)' imin=',imin,' dmin=',dmin
write(it,'(i1)')imin



open(1,file='../../../DATA/'//ar//'/'//md//'/data/ref'//it//'.dat')
open(11,file='../../../DATA/'//ar//'/'//md//'/data/refmod.dat')
read(1,*)
write(11,*)0
nref=0
182	read(1,*,end=181)h,vp,vs
	write(11,*)h,vp,vs
	nref=nref+1
	hmod(nref)=h
	vmodp(nref)=vp
	vmods(nref)=vs
goto 182
181	close(1)
close(11)
write(*,*)' nref=',nref

open(21,file='../../../TMP_files/1D_mod/ref_final.bln')
write(21,*)nref
do i=1,nref
	write(21,*)vmodp(i),-hmod(i)
end do
write(21,*)nref
do i=1,nref
	write(21,*)vmods(i),-hmod(i)
end do
close(21)

open(21,file='../../../DATA/'//ar//'/'//md//'/data/ref_final.bln')
write(21,*)nref
do i=1,nref
	write(21,*)vmodp(i),-hmod(i)
end do
write(21,*)nref
do i=1,nref
	write(21,*)vmods(i),-hmod(i)
end do
close(21)

key_preview=0
open(1,file='../../../preview_key.txt')
read(1,*,end=771)key_preview
771 close(1)

if(key_preview.ne.0) then
	write(*,*)'	 ****************************************************'
	write(*,*)'	 Visualization:'
	i=system('../../1_PRELIM_LOC/_vis_refmod/vis_refmod.exe')
end if

stop
end