character*8 ar,md,line
real tref(100000),dref(100000),alref(100000),href(100000)
real zst(20),dzst(20)

common/pi/pi,per

one=1.d0
pi=asin(one)*2.d0
per=pi/180.d0
rz=6371.

open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the model
close(1)

write(*,*)' Computing the reference table:'
write(*,*)' ar=',ar,' md=',md		



open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,*,end=553)line
	if(line.eq.'REF_PARA') goto 554
end do
553 continue
write(*,*)' cannot find REF_PARAM in MAJOR_PARAM.DAT!!!'
pause


554 read(1,*)
read(1,*)dmin		!=0.1
read(1,*)depmax		!=100.
read(1,*)distmax		!=2000.
read(1,*)nstep		
do i=1,nstep
	read(1,*)zst(i),dzst(i)
end do
read(1,*)zztmax		!=50.
close(1)

call read_vref(ar,md)


dzzt=dzst(1)
zout=0
zzt=zst(1)-dzzt
izt=0

open(11,file='../../../DATA/'//ar//'/'//md//'/data/table.dat',form='unformatted')
!open(31,file='table.dat')
!	do zzt=zztmin,zztmax,dzzt
34	zzt=zzt+dzzt
	if(zzt.gt.zztmax) goto 35
	izt=izt+1
	if(nstep.gt.1) then
		do istep=2,nstep
			if(zzt.gt.zst(istep)) dzzt=dzst(istep)
		end do
	end if

!if(izt.ne.17) goto 34	

!zzt=150
	
	do ips=1,2
		!write(*,*)' zzt=',zzt
		dlast=999
		nref=0
		!open(31,file='tmp.dat')
		do al=180, 0.d0, -0.02d0
		!do al=180, 0.d0, -0.02d0
			alfa0=al
            !alfa0=160
		!do alfa0=89.986, 0.d0, -0.002d0
			call reftrace(alfa0,zzt,zout,ips,1,  time,dist,hmax)
			!write(*,*)' alfa0=',alfa0,' dist=',dist,' hmax=',hmax,' time=',time
            !pause

			dgrad=(dist/rz)/per
		!	if (hmax.ge.hmod(nrefmod-1)) exit
			if(dist.lt.0.) cycle
			dkm=dist
			if(abs(dkm-dlast).gt.dmin) then
				nref=nref+1
				tref(nref)=time
				dref(nref)=dkm
				if(nref.eq.1)dref(nref)=0
				alref(nref)=alfa0
				href(nref)=hmax
				dlast=dkm
				!write(*,*)nref,alfa0,dist,time,hmax
				!write(31,*)nref,alfa0,dkm,time,hmax
			end if
			if (hmax.gt.depmax)exit 
			if (dist.gt.distmax)exit 
				
		end do
		!close(31)
		write(11)zzt,nref
		!write(31,*)zzt,nref
		if(mod(izt,10).eq.0) write(*,*)' i=',izt,' z=',zzt,' ips=',ips,' nref=',nref
		do i=1,nref
			write(11)dref(i),tref(i),alref(i),href(i)
			!write(31,*)dref(i),tref(i),alref(i),href(i)
			!write(*,*)dref(i),tref(i),alref(i),href(i)
		end do
		!pause
	end do
goto 34
35 close(11)
stop
end 
