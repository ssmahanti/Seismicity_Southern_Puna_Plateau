character*8 ar,md,line
integer nkr_z(1000,2000),kzt_z(1000,2000),nmx_z(1000)


common/krat/nkrat,istkr(500),tobkr(500),ipskr(500),qualkr(500),trfkr(500),ngood(500),alkr(500),diskr(500)


open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the area
write(*,*)' Selecting events for 1D optimization: area=',ar,' model=',md


key_coord_type=1
open(1,file='../../../data/'//ar//'/'//md//'/MAJOR_PARAM.DAT',status='old',err=562)
do i=1,10000
	read(1,'(a8)',end=563)line
	if(line.eq.'GENERAL ') goto 564
end do
562 continue
write(*,*)' file MAJOR_PARAM.DAT does not exist in ar=',ar,' md=',md
pause
563 continue
write(*,*)' cannot find GENERAL INFORMATION in MAJOR_PARAM.DAT!!!'
pause
564 continue
do i=1,4
    read(1,*)
end do
read(1,*,err=565)key_coord_type
565 close(1)


open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=553)line
	if(line.eq.'1D MODEL') goto 554
end do
553 continue
write(*,*)' cannot find 1D MODEL in MAJOR_PARAM.DAT!!!'
pause

554 read(1,*)
read(1,*)zmin,dzstep,nzmax
close(1)
nzt=0
nray=0
nkr_z=0
kzt_z=0
nmx_z=0

open(1,file='../../../DATA/'//ar//'/'//md//'/data/rays0.dat',form='unformatted')

1	read(1,end=2)xzt,yzt,zzt,nkrat
	nzt=nzt+1
	do i=1,nkrat
		read(1)istkr(i),ipskr(i),tobkr(i),trfkr(i)
	end do
	!write(*,*)xzt,yzt,zzt,nkrat
	do iz=1,1000
		z1=zmin+(iz-1)*dzstep
		z2=zmin+iz*dzstep
		if((zzt-z1)*(zzt-z2).le.0.)exit
	end do
	!write(*,*)' iz=',iz,' z1=',z1,'z2=',z2,' nkrat=',nkrat
	if(nmx_z(iz).lt.nzmax) then
		nmx_z(iz)=nmx_z(iz)+1
		kzt_z(iz,nmx_z(iz))=nzt
		nkr_z(iz,nmx_z(iz))=nkrat
	else
		nmin=9999
		do imx=1,nzmax
			if(nkr_z(iz,imx).ge.nmin) cycle
			nmin=nkr_z(iz,imx)
			imin=imx
		end do 
		if(nmin.lt.nkrat) then
			kzt_z(iz,imin)=nzt
			nkr_z(iz,imin)=nkrat
		end if
	end if

	!pause
	nray=nray+nkrat
	goto 1
2 close(1)
write(*,*)' nzt=',nzt,' nray=',nray

do iz=1,1000
	if(nmx_z(iz).eq.0) cycle
	z1=zmin+(iz-1)*dzstep
	z2=zmin+iz*dzstep
	write(*,'(f6.1,10i4)')z1,(nkr_z(iz,im),im=1,nmx_z(iz))
end do



nzt=0
izt=0
nray=0
open(1,file='../../../DATA/'//ar//'/'//md//'/data/rays0.dat',form='unformatted')
open(11,file='../../../DATA/'//ar//'/'//md//'/data/rays_selected.dat',form='unformatted')
11	if (key_coord_type.eq.1) then
            read(1,end=12)xzt,yzt,zzt,nkrat
        else
            read(1,end=12)xzt0,yzt0,zzt0
            read(1)xzt,yzt,zzt,nkrat
        end if
	izt=izt+1
	do i=1,nkrat
		read(1)istkr(i),ipskr(i),tobkr(i),trfkr(i)
	end do

	do iz=1,1000
		if(nmx_z(iz).eq.0) cycle
		do im=1,nmx_z(iz)
			if(kzt_z(iz,im).eq.izt) goto 14
		end do
	end do
	goto 11
14	continue
	

	nzt=nzt+1
	!if(mod(nzt,10).eq.0) write(*,*)xzt,yzt,zzt,nkrat
	nray=nray+nkrat
	write(11)xzt,yzt,zzt,nkrat
	do i=1,nkrat
		write(11)istkr(i),ipskr(i),tobkr(i),trfkr(i)
	end do
	goto 11
12 close(1)
close(11)
write(*,*)' nzt=',nzt,' nray=',nray

stop
end