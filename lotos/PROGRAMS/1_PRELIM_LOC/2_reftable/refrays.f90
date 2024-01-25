character*8 ar,md,line
character*1 rm,it
real tref(100000),dref(100000),alref(100000),href(100000)
real zst(20),dzst(20)

common/refmod/nrefmod,zref(600),vref(600,2)

common/pi/pi,per


one=1.d0
pi=asin(one)*2.d0
per=pi/180.d0
rz=6371.

open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the area
read(1,*)iter		! code of the area
close(1)
write(it,'(i1)')iter-1

write(*,*)' Computing the reference table:'
write(*,*)' ar=',ar,' md=',md,' it=',it		! code of the area


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



if(iter.eq.1) then
	open(1,file='../../../DATA/'//ar//'/'//md//'/data/ref_start.dat')
else
	open(1,file='../../../DATA/'//ar//'/'//md//'/data/ref'//it//'.dat')
end if
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
nrefmod=iref
write(*,*)' nrefmod=',nrefmod

do i=1,nrefmod
    write(*,*)zref(i),vref(i,1),vref(i,2)
end do


dzzt=dzst(1)
zout=0
zzt=zst(1)-dzzt
izt=0

open(11,file='../../../DATA/'//ar//'/'//md//'/data/table'//it//'.dat',form='unformatted')
!	do zzt=zztmin,zztmax,dzzt
34	zzt=zzt+dzzt
write(*,*)' zzt=',zzt
!pause
	if(zzt.gt.zztmax) goto 35
	izt=izt+1
	if(nstep.gt.1) then
		do istep=2,nstep
			if(zzt.gt.zst(istep)) dzzt=dzst(istep)
		end do
	end if
!	zzt=181

!if(izt.ne.17) goto 34	
	
	do ips=1,2
		dlast=999
		nref4=0
		!open(31,file='tmp.dat')
		do al=180, 0.d0, -0.005d0
			alfa0=al
		!do alfa0=89.986, 0.d0, -0.002d0
			call reftrace(alfa0,zzt,zout,ips,1,  time,dist,hmax)
			write(*,*)alfa0,dist,time,hmax
			dgrad=(dist/rz)/per
			!pause
		!	if (hmax.ge.hmod(nrefmod-1)) exit
			if(dist.lt.0.) cycle
			dkm=dist
			if(abs(dkm-dlast).gt.dmin) then
				nref4=nref4+1
				tref(nref4)=time
				dref(nref4)=dkm
				if(nref4.eq.1)dref(nref4)=0
				alref(nref4)=alfa0
				href(nref4)=hmax
				dlast=dkm
				write(*,*)nref4,alfa0,dist,time,hmax
                stop
				!pause
				!write(31,*)nref,alfa0,dkm,time,hmax
			end if
			if (hmax.gt.depmax)exit 
			if (dist.gt.distmax)exit 
				
		end do
		!close(31)
		write(11)zzt,nref4
		if(mod(izt,10).eq.0)write(*,*)' i=',izt,' z=',zzt,' ips=',ips,' nref=',nref4
		pause
		do i=1,nref4
			write(11)dref(i),tref(i),alref(i),href(i)
			!write(*,*)dref(i),tref(i),alref(i),href(i)
		end do
		!pause
	end do
goto 34
35 close(11)
stop
end 
