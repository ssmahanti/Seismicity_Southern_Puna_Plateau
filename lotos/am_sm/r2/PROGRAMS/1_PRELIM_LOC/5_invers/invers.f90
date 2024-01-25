!USE DFPORT

character*8 ar,md,line
character*1 it0,it1
real amat1(1000),amat_line(1000),zsharp(20)
integer kmat_line(1000)
real vpnew(1000),vsnew(1000),hnew(1000)

allocatable x(:),x0(:),u(:),v(:),w(:),aaa(:),dt(:),xmod(:)
allocatable ncolrow(:),ncol(:),sumat(:),wm_p(:),wm_s(:)

common/refmod/nref,zref(600),vref(600,2)


open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the area
read(1,*)iter
close(1)
write(it0,'(i1)')iter-1
write(it1,'(i1)')iter
write(*,*)' 1D INVERSION: area=',ar,' model=',md,' iter=',iter

i=system('mkdir ..\..\..\TMP_files\1D_mod')


open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=553)line
	if(line.eq.'1D MODEL') goto 554
end do
553 continue
write(*,*)' cannot find AREA CENTER in MAJOR_PARAM.DAT!!!'
pause

554 read(1,*)
read(1,*)zlim1,dzz,dzs
read(1,*)
read(1,*)dz_par
read(1,*)sum_porog
read(1,*)sm_p,sm_s
read(1,*)rg_p,rg_s
read(1,*)w_hor,w_ver,w_time
read(1,*)iter_lsqr
read(1,*)nsharp
read(1,*)(zsharp(i),i=1,nsharp)
close(1)

if(iter.eq.1) then
	open(1,file='../../../DATA/'//ar//'/'//md//'/data/ref_start.dat')
else
	open(1,file='../../../DATA/'//ar//'/'//md//'/data/ref'//it0//'.dat')
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
nref=iref
write(*,*)' nref=',nref

if(iter.eq.1) then
	open(21,file='../../../TMP_files/1D_mod/ref_start.bln')
	write(21,*)nref
	do i=1,nref
		write(21,*)vref(i,1),-zref(i)
	end do
	write(21,*)nref
	do i=1,nref
		write(21,*)vref(i,2),-zref(i)
	end do
	close(21)
	open(21,file='../../../DATA/'//ar//'/'//md//'/data/ref_start.bln')
	write(21,*)nref
	do i=1,nref
		write(21,*)vref(i,1),-zref(i)
	end do
	write(21,*)nref
	do i=1,nref
		write(21,*)vref(i,2),-zref(i)
	end do
	close(21)
end if



open(1,file='../../../DATA/'//ar//'/'//md//'/data/numb_1d.dat')
read(1,*)nray,nonz,nvel,nzt
close(1)
write(*,*)' nray=',nray,' nonz=',nonz

nonzer = nonz+nray*4
nrows = nray
ncols = nvel*2 + nzt*4


if(sm_p.gt.0.0001) then
	nonzer = nonzer + (nvel-1-nsharp) * 2
	nrows = nrows + (nvel-1-nsharp)
end if

if(sm_s.gt.0.0001) then
	nonzer = nonzer + (nvel-1-nsharp) * 2
	nrows = nrows + (nvel-1-nsharp)
end if

if(rg_p.gt.0.0001) then
	nonzer = nonzer + nvel 
	nrows = nrows + nvel
end if
if(rg_s.gt.0.0001) then
	nonzer = nonzer + nvel 
	nrows = nrows + nvel
end if

write(*,*)' nrows=',nrows,' ncols=',ncols,' nonzer=',nonzer

allocate(xmod(ncols),x(ncols),x0(ncols),v(ncols),w(ncols))
allocate(ncol(nrows),dt(nrows),u(nrows))
allocate(aaa(nonzer),ncolrow(nonzer),sumat(nvel*2),wm_p(nvel),wm_s(nvel))


open(1,file='../../../TMP_files/tmp/matr_1d.dat',form='unformatted')
ir=0
nonz=0
sumat=0

43	continue
	read(1,end=42)nuz,res,ips
	read(1)nzt,dtdx,dtdy,dtdz
	do i=1,nuz
		read(1)amat_line(i),kmat_line(i)
		n0=0
		if(ips.eq.2) n0=nvel
		!write(*,*)amat_line(i),kmat_line(i)+n0
		sumat(n0+kmat_line(i))=sumat(n0+kmat_line(i))+abs(amat_line(i))
	end do

	ir=ir+1

	dt(ir)=res			!!!!!!!!!!!!!!!!!!!!!!!!!
	ncol(ir) = nuz + 4

	n0=0
	if(ips.eq.2) n0=nvel

	dtsyn=0
	do ii=1,nuz
		nonz=nonz+1
		aaa(nonz) = amat_line(ii)
		ncolrow(nonz)= n0 + kmat_line(ii)

		!par=0.
		!zcur=(kmat_line(ii)-1)*dz_par
		!if((zcur-20)*(zcur-50).lt.0.) par=0.1
		!dtsyn=dtsyn+par*amat_line(ii)

	end do
	!dt(ir)=dtsyn
	!write(*,*)nuz,dtsyn,ips

	nonz=nonz+1
	aaa(nonz) = dtdx * w_hor
	ncolrow(nonz)= nvel*2+(nzt-1)*4+1
	nonz=nonz+1
	aaa(nonz) = dtdy * w_hor
	ncolrow(nonz)= nvel*2+(nzt-1)*4+2
	nonz=nonz+1
	aaa(nonz) = dtdz * w_ver
	ncolrow(nonz)= nvel*2+(nzt-1)*4+3
	nonz=nonz+1
	aaa(nonz) = w_time
	ncolrow(nonz)= nvel*2+(nzt-1)*4+4

	goto 43
42 close(1)
write(*,*)' ir=',ir,' nonz=',nonz


avsum1=0
avsum2=0

do i=1,nvel
	!write(*,*)i,sumat(i),sumat(nvel+i)
	avsum1=avsum1+sumat(i)
	avsum2=avsum2+sumat(nvel+i)
end do
avsum1=avsum1/nvel
avsum2=avsum2/nvel
!write(*,*)' avsum1=',avsum1,' avsum2=',avsum2

do i=1,nvel
	sumn=sumat(i)/avsum1
	if(sumn.gt.sum_porog) then
		wm_p(i)=1
	else
		wm_p(i)=sumn/sum_porog
	end if

	sumn=sumat(nvel+i)/avsum2
	if(sumn.gt.sum_porog) then
		wm_s(i)=1
	else
		wm_s(i)=sumn/sum_porog
	end if
	!write(*,*)i,' wm_p=',wm_p(i),' wm_s=',wm_s(i)
end do
!wm_p(1)=1
!wm_s(1)=1

kount=0
do irw=1,ir
	!write(*,*)' irw=',irw 
	do ii=1,ncol(irw)
		kount=kount+1
		nn=ncolrow(kount)
		if(nn.gt.nvel*2) then
			wm=1
		else if(nn.gt.nvel.and.nn.le.nvel*2) then
			wm=wm_s(nn-nvel)
		else if(nn.le.nvel) then
			wm=wm_p(nn)
		end if
		aaa(kount)=aaa(kount)*wm
		!write(*,*)' nn=',nn,' aaa(kount)=',aaa(kount),' wm=',wm
	end do
end do



if(sm_p.gt.0.0001) then
	do i=1,nvel-1
		z1=(i-1)*dz_par
		z2=i*dz_par
		if(nsharp.ne.0) then
			do ish=1,nsharp
				if(zsharp(ish).eq.z1) goto 339
				if((zsharp(ish)-z1)*(zsharp(ish)-z2).lt.0) then
					write(*,*)' P sharp:',i,' z1=',z1,' z2=',z2
					goto 339
				end if
			end do
		end if

		ir=ir+1
		dt(ir)=0.
		ncol(ir)=2
		!write(*,*)' ir=',ir,' y1=',y1,' y2=',y2

		nonz=nonz+1
		aaa(nonz)=sm_p
		ncolrow(nonz) = i

		nonz=nonz+1
		aaa(nonz)=-sm_p
		ncolrow(nonz) = i+1
339 continue
	end do
end if

if(sm_s.gt.0.0001) then
	do i=1,nvel-1
		z1=(i-1)*dz_par
		z2=i*dz_par
		if(nsharp.ne.0) then
			do ish=1,nsharp
				if(zsharp(ish).eq.z1) goto 338
				if((zsharp(ish)-z1)*(zsharp(ish)-z2).lt.0) then
					write(*,*)' S sharp:',i,' z1=',z1,' z2=',z2
					goto 338
				end if
			end do
		end if


		ir=ir+1
		dt(ir)=0.
		ncol(ir)=2
		!write(*,*)' ir=',ir,' y1=',y1,' y2=',y2

		nonz=nonz+1
		aaa(nonz)=sm_s
		ncolrow(nonz) = nvel + i

		nonz=nonz+1
		aaa(nonz)=-sm_s
		ncolrow(nonz) = nvel + i+1
338		continue
	end do
end if

if(rg_p.gt.0.0001) then
	do i=1,nvel
		ir=ir+1
		dt(ir)=0.
		ncol(ir)=1

		nonz=nonz+1
		aaa(nonz) = rg_p
		ncolrow(nonz) = i
	end do
end if

if(rg_s.gt.0.0001) then
	do i=1,nvel
		ir=ir+1
		dt(ir)=0.
		ncol(ir)=1

		nonz=nonz+1
		aaa(nonz) = rg_s
		ncolrow(nonz) = nvel + i
	end do
end if




nz=nonz
nr=ir

do i=1,nr
	u(i)=dt(i)
end do


kount=0
do irw=1,nr
	!write(*,*)' irw=',irw,' dt=',u(irw)
	do ii=1,ncol(irw)
		kount=kount+1
		nn=ncolrow(kount)
		!write(*,*)' nn=',nn,' aaa=',aaa(kount)
		if(abs(u(irw)).gt.1.e10) then
			write(*,*)' Warning!!!'
			write(*,*)' dt=',u(irw)
			pause
		end if
		if(abs(aaa(kount)).gt.1.e10) then
			write(*,*)' Warning!!!'
			write(*,*)' aaa=',aaa(kount)
			pause
		end if
		if(nn.le.0.or.nn.gt.ncols) then
			write(*,*)' Warning!!!'
			write(*,*)' irw=',irw,' nn=',nn
			pause
		end if
	end do
end do
write(*,*)' N rows=',nr,' N columns=',ncols,' N nonzer=',nz
write(*,*)

!*******************************************************
!*******************************************************
!*******************************************************
call pstomo(nr,ncols,x,u,v,w,iter_lsqr,nz,aaa,ncolrow,ncol)
!*******************************************************
!*******************************************************
!*******************************************************

err=0
kount=0
avres=0.
avres0=0.
dtvel=0
dtsta=0
dtztr=0
!write(*,*)' nray=',nray
do irw=1,nray
	dt1=0
	do ii=1,ncol(irw)
		kount=kount+1
		nn=ncolrow(kount)
		dt1=dt1+aaa(kount)*x(nn)
		!write(*,*)' aaa(kount)*x(nn)',aaa(kount)*x(nn)
	end do
	!write(*,*)' dt(irw)=',dt(irw),' dt1=',dt1
	avres=avres+abs(dt(irw)-dt1)
	avres0=avres0+abs(dt(irw))
end do
avres=avres/nray
avres0=avres0/nray
reduct=((avres0-avres)/avres0)*100.

!write(*,*)'_____________________________________________________________'
write(*,*)' avres0=',avres0,' avres=',avres,' red=',reduct
!write(*,*)'_____________________________________________________________'

open(11,file='../../../DATA/'//ar//'/'//md//'/data/ref'//it1//'.dat')
write(11,*)0
do iz=1,nvel
	zcur=zlim1+(iz-1)*dz_par
	vold_p=vrefmod(zcur,1)
	vold_s=vrefmod(zcur,2)
	dv_p = x(iz)*wm_p(iz)
	dv_s = x(nvel+iz)*wm_s(iz)
	vnew_p = vold_p + dv_p
	vnew_s = vold_s + dv_s
	write(11,*)zcur,vnew_p,vnew_s,dv_p,dv_s
	vpnew(iz)=vnew_p
	vsnew(iz)=vnew_s
	hnew(iz)=zcur
end do

zmax=nvel*dz_par+20
if(zmax.gt.zref(nref)) then
	vpmax=vrefmod(zmax,1)
	vsmax=vrefmod(zmax,2)
	hmax=zmax
else
	do i=1,nref
		if(zref(i).lt.zmax) cycle
		hmax=zref(i)
		vpmax=vref(i,1)
		vsmax=vref(i,2)
		exit
	end do
end if

write(11,*)hmax,vpmax,vsmax

nvel=nvel+1
vpnew(nvel)=vpmax
vsnew(nvel)=vsmax
hnew(nvel)=hmax

nvel=nvel+1
vpnew(nvel)=vref(nref,1)
vsnew(nvel)=vref(nref,2)
hnew(nvel)=zref(nref)

write(11,*)zref(nref),vref(nref,1),vref(nref,2)
close(11)

open(21,file='../../../TMP_files/1D_mod/ref'//it1//'.bln')
write(21,*)nvel
do i=1,nvel
	write(21,*)vpnew(i),-hnew(i)
end do

write(21,*)nvel
do i=1,nvel
	write(21,*)vsnew(i),-hnew(i)
end do
close(21)


stop
end