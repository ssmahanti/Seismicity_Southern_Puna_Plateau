character*8 ar,md,line
character*1 ps,rm,it 
integer nrps(2)

allocatable dvan(:,:),vvv(:,:),vtmp(:,:),dv_3d(:,:,:),van_p(:,:,:)

common/pi/pi,per
common/center/fi0,tet0

w_limit=0.2

one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0
rz=6371.



open(1,file='../../../model.dat')
read(1,'(a8)')ar
read(1,'(a8)')md
read(1,*)iter		! code of the grid
close(1)
write(it,'(i1)')iter

write(*,*)' ar=',ar,' model : ',md,' iter=',iter

call read_vref(ar,md)


!******************************************************************
open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=563)line
	if(line.eq.'3D_MODEL') goto 564
end do
563 continue
write(*,*)' cannot find 3D_MODEL in MAJOR_PARAM.DAT!!!'
pause
564 continue
read(1,*) xx1,xx2,dxx 
read(1,*) yy1,yy2,dyy 
read(1,*) zz1,zz2,dzz  
read(1,*) smaxx
read(1,*) ismth
close(1)
!******************************************************************
rsmth=ismth+0.5
nxx=(xx2-xx1)/dxx+1
nyy=(yy2-yy1)/dyy+1
nzz=(zz2-zz1)/dzz+1
write(*,*)' nxx=',nxx,' nyy=',nyy,' nzz=',nzz

!******************************************************************
open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=573)line
	if(line.eq.'ORIENTAT') goto 574
end do
573 continue
write(*,*)' cannot find ORIENTATIONS in MAJOR_PARAM.DAT!!!'
pause
574 read(1,*)nornt
close(1)
!******************************************************************


open(1,file='../../../DATA/'//ar//'/'//md//'/data/numray1.dat')
read(1,*) nrps(1),nrps(2)
close(1)



allocate(dvan(nxx,nyy),vvv(nxx,nyy),vtmp(nxx,nyy))
allocate(dv_3d(nxx,nyy,nzz),van_p(nxx,nyy,nzz))

do ips=1,2
	write(ps,'(i1)')ips

	if(nrps(ips).eq.0) then
		open(11,file='../../../DATA/'//ar//'/'//md//'/data/dv_v'//ps//it//'.dat',form='unformatted')
		write(11)0,0,0
		write(11)0,0,0
		write(11)0,0,0
		close(11)
		cycle
	end if
	dv_3d=0

	do izz=1,nzz

		zzz=(izz-1)*dzz+zz1
		vp0=vrefmod(zzz,1)
		vs0=vrefmod(zzz,2)
		vpvs0=vp0/vs0

		v0 = vrefmod(zzz,ips)
		if(mod(izz,5).eq.0) write(*,*)' izz=',izz,' zzz=',zzz
		vvv=0
		dvan=0
		do igr=1,nornt
			if(ips.eq.1) then
				call prepare_model_v(ar,md,1,iter,igr)
			else if(ips.eq.2) then
				call prepare_model_x(ar,md,iter,igr)
			end if

			vvv=0
			dvan=0
			DO iyy=1,nyy
			!DO iyy=76,76
				yyy=(iyy-1)*dyy+yy1
				do ixx=1,nxx
				!do ixx=76,76
					xxx=(ixx-1)*dxx+xx1
					!xxx=30
					dv=0
					www=0
					!write(*,*)xxx,yyy,zzz
					call dv_1_gr_xyz_v(xxx,yyy,zzz,smaxx, dv,www)
					!write(*,*)igr,' dv=',dv,' www=',www
					dvan(ixx,iyy)=dvan(ixx,iyy)+dv*www
					vvv(ixx,iyy)=vvv(ixx,iyy)+www
				end do
			end do
		end do

		!write(*,*)izz,' 1: dvan(76,76)=',dvan(76,76),vvv(76,76)

		!write(*,*)' mark1'

! Absolute values of anomalies:
		do iyy=1,nyy
			yyy=(iyy-1)*dyy+yy1
			do ixx=1,nxx
				vanm=0.
				if (vvv(ixx,iyy).gt.w_limit) then
					vanm=dvan(ixx,iyy)/vvv(ixx,iyy)
				end if
				vtmp(ixx,iyy)=vanm
			end do
		end do
		dvan=vtmp
	!write(*,*)ilev,' 2: dvan(86,10)=',dvan(86,10)
		!write(*,*)' mark2'

! Smoothing:
		do ixx=1,nxx
			do iyy=1,nyy
				if(vvv(ixx,iyy).lt.w_limit) cycle
				vanm=0.
				iv=0
				do ix2=-ismth,ismth
					if (ixx+ix2.lt.1) cycle
					if (ixx+ix2.gt.nxx) cycle
					do iy2=-ismth,ismth
						if (iyy+iy2.lt.1) cycle
						if (iyy+iy2.gt.nyy) cycle
						!if(vvv(ixx+ix2,iyy+iy2).lt.w_limit) cycle
						rr=ix2*ix2+iy2*iy2
						r=sqrt(rr)
						if(r.gt.rsmth) cycle
						iv=iv+1
						vanm=vanm+dvan(ixx+ix2,iyy+iy2)
					end do
				end do
				vtmp(ixx,iyy)=vanm/iv
			end do
		end do
		dvan=vtmp
	!write(*,*)ilev,' 3: dvan(86,10)=',dvan(86,10)
		!write(*,*)' izz=',izz,' nzz=',nzz

		if(ips.eq.2) then
			do ixx=1,nxx
				do iyy=1,nyy
					vanm=0
					if (vvv(ixx,iyy).lt.w_limit) goto 771

					vp = dv_3D(ixx,iyy,izz) + vp0
					vpvs= vpvs0+dvan(ixx,iyy)
					vs=vp/vpvs
					!write(*,*)' vp=',vp,' vpvs=',vpvs,' vs=',vs
					!write(*,*)' vp0=',vp0,' vpvs0=',vpvs0,' vs0=',vs0
					!pause
					vanm= vs-vs0
771					vtmp(ixx,iyy)=vanm
				end do
			end do
			dvan=vtmp
		end if
		do ixx=1,nxx
			do iyy=1,nyy
				dv_3D(ixx,iyy,izz)=dvan(ixx,iyy)
			end do
		end do
	end do		! izz=1,nzz

	open(11,file='../../../DATA/'//ar//'/'//md//'/data/dv_v'//ps//it//'.dat',form='unformatted')
	write(11)xx1,nxx,dxx
	write(11)yy1,nyy,dyy
	write(11)zz1,nzz,dzz
	write(*,*)' nx=',nxx,' ny=',nyy,' nz=',nzz
	do izz=1,nzz
		write(11)((dv_3D(ixx,iyy,izz),ixx=1,nxx),iyy=1,nyy)
	end do
	close(11)
	!write(*,*)' dv_3D(86,25,10)=',dv_3D(86,25,10)

end do


stop
end
