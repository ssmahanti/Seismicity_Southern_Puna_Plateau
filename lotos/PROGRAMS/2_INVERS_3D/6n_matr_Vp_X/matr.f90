character*8 ar,md,line
character*1 it,itold,ppss,atest,rm,gr

integer istkr(500),ipskr(500)
real tobkr(500),tmdkr(500)

integer isttmp(500),ipstmp(500)
real tobtmp(500),tmdtmp(500)

real xray(1000),yray(1000),zray(1000)
real xold(1000),yold(1000),zold(1000)
real resid(100),ztest(4),yprof(10,50)

integer iotper(100),iotr4(4),nlev(2),nobr(2)

real  xtop(:,:,:), ztop(:,:,:),vtop(:,:,:),xxxtop(:,:,:)
integer popor(:,:,:),obr(:,:,:),kod_otr(:,:,:,:),notr(:,:),ntop(:,:)
real ornt(20),ylevel(:,:)


real zper(100),votr(4),zotr(4),vaver(8),xaver(8)

real vertet(4,3),vtoptet(4)
real d00(1250),r00(1250)
real aa8(4,4),q8(4),a8(4)
real aa(4,4),q(4),a(4),curr(3)
integer iuz(8),nurr(8),muzel(1200)
real matr(9960),matruzel(1200)
real amatold(1200)
integer muzold(1200)

integer npar(50),nprof(10),nrps(2)

common/refmod/nrefmod,zref(600),vref(600,2)


allocatable xtop,ztop,vtop,xxxtop
allocatable popor,obr,kod_otr,notr,ntop,ylevel

one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0

k_reject=1


open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the area
read(1,*)iter		! code of the grid
read(1,*)igr		! code of the grid
close(1)

write(it,'(i1)')iter
write(gr,'(i1)')igr

write(*,*)' execution of matr'
write(*,*)' ar=',ar,' md=',md,' it=',it,' gr=',gr


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
read(1,*)(ornt(i),i=1,nornt)
close(1)

orient=ornt(igr)
write(*,*)' orient=',orient
sinbase=sin(orient*per)
cosbase=cos(orient*per)

!******************************************************************
open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=553)line
	if(line.eq.'AREA_CEN') goto 554
end do
553 continue
write(*,*)' cannot find AREA CENTER in MAJOR_PARAM.DAT!!!'
pause
554 read(1,*)fi0,tet0
write(*,*)fi0,tet0
close(1)

!******************************************************************
open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=533)line
	if(line.eq.'GRID_PAR') goto 534
end do
533 continue
write(*,*)' cannot find GRID_PARAMETERS in MAJOR_PARAM.DAT!!!'
pause
534 continue
read(1,*)xlim1,xlim2,dxpl
read(1,*)ylim1,ylim2,dypl
read(1,*)zlim1,zlim2,dzpl
close(1)
!******************************************************************

nsurf=0

call read_vref(ar,md)

call read_3D_mod_v(ar,md,iter-1)


!vvv=velocity(30.,20.,40.,1)


!call prepare_model(md)
!call prepare_dv(itstep,md)


!**************************************************************
!*    Read initial parameters of grid

nmax=0
notmax=0

open(1,file='../../../DATA/'//ar//'/'//md//'/data/numray1.dat')
read(1,*) nrps(1),nrps(2)
close(1)


do iiips=1,2
	if(nrps(iiips).eq.0) cycle
	write(ppss,'(i1)')iiips
	open(1,file='../../../DATA/'//ar//'/'//md//'/data/levinfo'//ppss//gr//'.dat')
	i=0
	722 i=i+1
		read(1,*,end=721)n,y
		goto 722
	721 nypl=i-1
	write(*,*)' nypl=',nypl
	nlev(iiips)=nypl
	close(1)

	open(1,file='../../../DATA/'//ar//'/'//md//'/data/gr'//ppss//gr//'.dat')
	do n=1,nypl
		read(1,*)nt
		if(nt.gt.nmax) nmax=nt
		do i=1,nt
			read(1,*)x,z,l
		end do
	end do
	close(1)

	open(4,file='../../../TMP_files/tmp/otr'//ppss//gr//'.dat')
	do nur=1,nypl
		read(4,*) no
		if(no.gt.notmax) notmax=no
		read(4,*) ((ll, i=1,2), j=1,no)
	end do
	close(4)

	open(1,file='../../../DATA/'//ar//'/'//md//'/data/obr'//ppss//gr//'.dat')
	read(1,*) nobr(iiips)
	close(1)


end do
nymax=nlev(1)
if(nlev(2).gt.nymax) nymax=nlev(2)

ntmax=nobr(1)
if(nobr(2).gt.ntmax) ntmax=nobr(2)

write(*,*)' nymax=',nymax,' ntmax=',ntmax
write(*,*)' nmax=',nmax,' otr nmax=',notmax


allocate(ntop(2,nymax),ylevel(2,nymax))
allocate(xtop(2,nmax,nymax),ztop(2,nmax,nymax))
allocate(vtop(4,nmax,nymax),popor(2,nmax,nymax),xxxtop(2,nmax,nymax))
allocate(kod_otr(2,2,notmax,nymax),notr(2,nymax))
allocate(obr(2,ntmax,2))

do iiips=1,2
	if(nrps(iiips).eq.0) cycle
	write(ppss,'(i1)')iiips

	open(1,file='../../../DATA/'//ar//'/'//md//'/data/levinfo'//ppss//gr//'.dat')
	do i=1,nlev(iiips)
		read(1,*)ntop(iiips,i),ylevel(iiips,i)
	end do
	close(1)

	open(1,file='../../../DATA/'//ar//'/'//md//'/data/gr'//ppss//gr//'.dat')
	do n=1,nlev(iiips)
		read(1,*)nt
		ntop(iiips,n)=nt
		do i=1,ntop(iiips,n)
			read(1,*)xtop(iiips,i,n),ztop(iiips,i,n),popor(iiips,i,n)
			xx=xtop(iiips,i,n)
			yy=ylevel(iiips,n)
			zz=ztop(iiips,i,n)
			vtop(iiips,i,n)=velocity(xx,yy,zz,iiips)
			if(iiips.eq.1) then
				vtop(3,i,n)=velocity(xx,yy,zz,2)
				xxxtop(1,i,n)=vtop(1,i,n)/vtop(3,i,n)
			end if
			if(iiips.eq.2) then
				vtop(4,i,n)=velocity(xx,yy,zz,1)
				xxxtop(2,i,n)=vtop(4,i,n)/vtop(2,i,n)
			end if
		end do
	end do
	close(1)

	open(4,file='../../../TMP_files/tmp/otr'//ppss//gr//'.dat')
	do nur=1,nlev(iiips)
		read(4,*) notr(iiips,nur)
		read(4,*) ((kod_otr(iiips,i,j,nur), i=1,2), j=1,notr(iiips,nur))
	end do

	close(4)


	open(1,file='../../../DATA/'//ar//'/'//md//'/data/obr'//ppss//gr//'.dat')
	read(1,*) nobr(iiips)
	read(1,*)((obr(iiips,i,j),i=1,nobr(iiips)), j=1,2)
	close(1)
	write(*,*)' number of velocity parameters=',nobr(iiips)
end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


nzt=0
nray=0
nrp=0
nrs=0
nrr=0
nonzer=0
nonz_p=0
nonz_s=0

dtdxold=0
dtdyold=0
dtdzold=0


nr=0

open(1,file='../../../DATA/'//ar//'/'//md//'/data/rays'//it//'.dat',form='unformatted')
open(2,file='../../../TMP_files/tmp/ray_paths_'//it//'.dat',form='unformatted')


open(11,file='../../../TMP_files/tmp/vpvs_matr'//it//gr//'.dat',form='unformatted')
open(21,file='tmp.dat')

728 continue

	read(1,end=729)xzt,yzt,zzt,nkrat
	nzt=nzt+1
	write(*,*)nzt,xzt,yzt,zzt,nkrat
!write(*,*)' nrefmod=',nrefmod
	vzt1=velocity(xzt,yzt,zzt,1)
	vzt2=velocity(xzt,yzt,zzt,2)
!write(*,*)' vzt1=',vzt1,' vzt2=',vzt2

	if(nkrat.eq.0) goto 728

	ik=0
	istold=0
	do ikr=1,nkrat
		read(1,end=729)ist,ips0,tobs,tmod
		istkr(ikr)=ist
		ipskr(ikr)=ips0
		tobkr(ikr)=tobs
		tmdkr(ikr)=tmod
		write(*,*)ist,ips0,tobs,tmod
	end do



	! Reorder the picks so that S pick is placed after 
	! corresponding P pick:

	!write(*,*)
	!write(*,*)' nkrat=',nkrat
	!do i=1,nkrat
	!	write(*,*)ipskr(i),istkr(i),tobkr(i),tmdkr(i)
	!end do
goto 441
	itmp=0
	do ik1=1,nkrat
		ist1=istkr(ik1)
		ips1=ipskr(ik1)
		if(ips1.ne.2)cycle
		do ik2=1,nkrat
			ist2=istkr(ik2)
			ips2=ipskr(ik2)
			if(ips2.ne.1) cycle
			if(ist2.eq.ist1) goto 651

		end do 
		cycle

	651	continue

		itmp=itmp+1
		isttmp(itmp)=ist2
		ipstmp(itmp)=1
		tobtmp(itmp)=tobkr(ik2)
		tmdtmp(itmp)=tmdkr(ik2)
		istkr(ik2)=0

		itmp=itmp+1
		isttmp(itmp)=ist1
		ipstmp(itmp)=2
		tobtmp(itmp)=tobkr(ik1)
		tmdtmp(itmp)=tmdkr(ik1)
		istkr(ik1)=0
	end do

	do ikr=1,nkrat
		ist=istkr(ikr)
		ips=ipskr(ikr)
		if(ist.eq.0) cycle
		if(ips.eq.2) cycle
		itmp=itmp+1
		isttmp(itmp)=ist
		ipstmp(itmp)=ipskr(ikr)
		tobtmp(itmp)=tobkr(ikr)
		tmdtmp(itmp)=tmdkr(ikr)
	end do

	nkrat=itmp
	istkr=isttmp
	ipskr=ipstmp
	tobkr=tobtmp
	tmdkr=tmdtmp


	!write(*,*)
	!write(*,*)' nkrat=',nkrat
	!do i=1,nkrat
	!	write(*,*)ipskr(i),istkr(i),tobkr(i),tmdkr(i)
	!end do
	!pause
	!goto 728

441 continue

	do ikr=1,nkrat
		ist=istkr(ikr)
		ips0=ipskr(ikr)
		tobs=tobkr(ikr)
		tmod=tmdkr(ikr)
		res=tobs-tmod

		read(2)npr

!write(*,*)' *********** nzt=',nzt,' ikr=',ikr,' npr=',npr

		if(npr.eq.0)cycle
		do i=1,npr
			read(2)xray(i),yray(i),zray(i)
		end do


!if(nzt.lt.44) cycle

		!write(*,*)' nzt=',nzt,' ikr=',ikr,' npr=',npr
		!do i=1,npr
			!write(*,*)xray(i),yray(i),zray(i)
		!end do

		if(ips0.eq.2) then
			!if(ikr.eq.1) then
				!write(*,*)' nzt=',nzt,' ikr=',ikr,' ips0=',ips0
				!write(*,*)' Problem: fist pick is S'
				!pause
				!cycle
			!end if
			do ikr2=1,nkrat
				if(ikr.eq.ikr2) cycle
				if(ipskr(ikr2).ne.1) cycle
				if(istkr(ikr2).ne.ist) cycle
				goto 992
			end do
			!do ikr2=1,ikr-1
				!write(*,*)ipskr(ikr2),istkr(ikr2)
			!end do
			!write(*,*)' nzt=',nzt,' ikr=',ikr,' ips0=',ips0,' ist=',ist
			!write(*,*)' Problem: cannot find pair for S'
			!pause
			cycle
			992 continue
			!if(ikr-ikr2.gt.1) then
			!	do ikr3=1,ikr-1
			!		write(*,*)ipskr(ikr3),istkr(ikr3)
			!	end do
			!	write(*,*)' nzt=',nzt,' ikr=',ikr,' ikr2=',ikr2
			!	write(*,*)' Problem: S pick is not directly after P'
			!	pause
			!	cycle
			!end if
			!write(*,*)' ikr=',ikr,' ikr2=',ikr2
			dtp=tobkr(ikr2)-tmdkr(ikr2)
			dts=tobkr(ikr)-tmdkr(ikr)
			dtdiff=dts-dtp
			res=dtdiff
			!write(*,*)' dtp=',dtp,' dts=',dts,' dtdiff=',dtdiff
		end if

		nr=nr+1
		s0=1/vzt1
		if(ips0.ne.1) s0=1/vzt2
		x1=xray(1)
		y1=yray(1)
		z1=zray(1)
		x2=xray(2)
		y2=yray(2)
		z2=zray(2)

		hor=sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
		tot=sqrt(hor*hor+(z2-z1)*(z2-z1))

		cosbe=(x2-x1)/hor
		sinbe=(y2-y1)/hor
		!write(*,*)' dx=',x2-x1,' dy=',y2-y1,' dz=',z2-z1

		cosal=(z2-z1)/tot
		sinal=hor/tot

		dtdx=cosbe*sinal*s0
		dtdy=sinbe*sinal*s0
		dtdz=cosal*s0


		!if(nr.lt.7) cycle

		if(abs(res).gt.5) cycle


!if(ips0.eq.2) cycle




		!write(*,*)' npr=',npr

		n12=1
		if(ips0.eq.2) then
			n12=2
			dtdx=dtdx-dtdxold
			dtdy=dtdy-dtdyold
			dtdz=dtdz-dtdzold
		else
			dtdxold=dtdx
			dtdyold=dtdy
			dtdzold=dtdz
		end if


		write(11)res,ist,ips0,nzt
		write(11)dtdx,dtdy,dtdz
		nray=nray+1

		do ipsgr=1,n12
			matr=0.
			if(ips0.eq.2.and.ipsgr.eq.1) then
				do i=1,nuzold
					ipop=muzold(i)
					matr(ipop)= - amatold(i)
				end do
			end if

			do ipt=2,npr
				x1=xray(ipt-1)
				y1=yray(ipt-1)
				z1=zray(ipt-1)
				x2=xray(ipt)
				y2=yray(ipt)
				z2=zray(ipt)
				ds=sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1)+(z2-z1)*(z2-z1))
				xmid=(x1+x2)/2.
				ymid=(y1+y2)/2.
				zmid=(z1+z2)/2.

				xxx=xmid*cosbase+ymid*sinbase
				yyy=-xmid*sinbase+ymid*cosbase
				zzz=zmid

				do n=1,nlev(ipsgr)-1
					yl1=ylevel(ipsgr,n)
					yl2=ylevel(ipsgr,n+1)
					if ((yyy-yl1)*(yyy-yl2).le.0.) exit
				end do
				nur=n
				nur1=nur
				nur2=nur+1

				ips123=ipsgr
				if(n12.eq.2.and.ipsgr.eq.1) ips123=3	! S-ray path in the grid for P model


	224			continue
				if((xxx-xlim1)*(xxx-xlim2).ge.0.) cycle
				if((yyy-ylim1)*(yyy-ylim2).ge.0.) cycle
				if((zzz-zlim1)*(zzz-zlim2).ge.0.) cycle


				iper=0
				do iotr=1,notr(ipsgr,nur1)
					np1=kod_otr(ipsgr,1,iotr,nur1)
					np2=kod_otr(ipsgr,2,iotr,nur1)
					xp1=xtop(ipsgr,np1,nur1)
					xp2=xtop(ipsgr,np2,nur1)
					if(abs(xp1-xp2).lt.0.00001) cycle
					if((xp1-xxx)*(xp2-xxx).gt.0.) cycle
	!				write(*,*)' xp1=',xp1,' xp2=',xp2
					zp1=ztop(ipsgr,np1,nur1)
					zp2=ztop(ipsgr,np2,nur1)
					iper=iper+1
					zper(iper)=zp1+((zp2-zp1)/(xp2-xp1))*(xxx-xp1)
					iotper(iper)=iotr
					!write(*,*)' zp=',zper(iper),' iotr=',iotr
				end do

				do ip=2,iper
					z1=zper(ip-1)
					z2=zper(ip)
					if((z1-zzz)*(z2-zzz).le.0.) goto 710
				end do


				write(*,*)' xxx=',xxx,' yyy=',yyy,' zzz=',zzz
				write(*,*)' out of the study volume'
				pause
	710			continue
				iotr4(1)=iotper(ip-1)
				iotr4(2)=iotper(ip)
				!write(*,*)' iotr1=',iotr4(1),' iotr2=',iotr4(2)


				iper=0
				do iotr=1,notr(ipsgr,nur2)
					np1=kod_otr(ipsgr,1,iotr,nur2)
					np2=kod_otr(ipsgr,2,iotr,nur2)
					xp1=xtop(ipsgr,np1,nur2)
					xp2=xtop(ipsgr,np2,nur2)
					if(abs(xp1-xp2).lt.0.00001) cycle
					if((xp1-xxx)*(xp2-xxx).gt.0.) cycle
					zp1=ztop(ipsgr,np1,nur2)
					zp2=ztop(ipsgr,np2,nur2)
					!write(*,*)iotr,' x1=',xp1,xp2,' z1=',zp1,zp2
					iper=iper+1
					zper(iper)=zp1+((zp2-zp1)/(xp2-xp1))*(xxx-xp1)
					iotper(iper)=iotr
				end do


				do ip=2,iper
					z1=zper(ip-1)
					z2=zper(ip)
					if((z1-zzz)*(z2-zzz).le.0.) goto 711
				end do

				write(*,*)' xxx=',xxx,' yyy=',yyy,' zzz=',zzz
				write(*,*)' out of the study volume'
				pause
	711			continue
				iotr4(3)=iotper(ip-1)
				iotr4(4)=iotper(ip)
				!write(*,*)' iotr3=',iotr4(3),' iotr4=',iotr4(4)

				iinf=0
				do iotr=1,4
					nnn=nur1
					if(iotr.gt.2) nnn=nur2
					do iside=1,2
						iuzz=kod_otr(ipsgr,iside,iotr4(iotr),nnn)
						imatr=popor(ipsgr,iuzz,nnn)
						if(imatr.eq.0) cycle
						if(iinf.ne.0) then
							do in=1,iinf
								if(iuz(in).eq.iuzz.and.nurr(in).eq.nnn) goto 712
							end do
						end if
						iinf=iinf+1
						!write(*,*)iinf,iuzz,nnn,imatr
						iuz(iinf)=iuzz
						nurr(iinf)=nnn
				!write(*,*)' iuz=',iuz(1),' nurr=',nurr(1)
						vaver(iinf)=vtop(ips123,iuzz,nnn)
						xaver(iinf)=xxxtop(ipsgr,iuzz,nnn)
				!write(*,*)' iuz=',iuz(1),' nurr=',nurr(1)
	712					continue
					end do
				end do

				
				do iotr=1,4
					nnn=nur1
					if(iotr.gt.2) nnn=nur2
					ii1=kod_otr(ipsgr,1,iotr4(iotr),nnn)
					x1=xtop(ipsgr,ii1,nnn)
					z1=ztop(ipsgr,ii1,nnn)
					v1=vtop(ips123,ii1,nnn)
					ii2=kod_otr(ipsgr,2,iotr4(iotr),nnn)
					x2=xtop(ipsgr,ii2,nnn)
					z2=ztop(ipsgr,ii2,nnn)
					v2=vtop(ips123,ii2,nnn)
					!write(*,*)' v1=',v1,' v2=',v2
					votr(iotr)=v1+((v2-v1)/(x2-x1))*(xxx-x1)
					zotr(iotr)=z1+((z2-z1)/(x2-x1))*(xxx-x1)
				end do
				z11=zotr(1)
				z21=zotr(2)
				z12=zotr(3)
				z22=zotr(4)
				v11=votr(1)
				v21=votr(2)
				v12=votr(3)
				v22=votr(4)
				!write(*,*)' v11=',v11,' v21=',v21
				!write(*,*)' v12=',v12,' v22=',v22
				vv1=v11+((v21-v11)/(z21-z11))*(zzz-z11)
				vv2=v12+((v22-v12)/(z22-z12))*(zzz-z12)
				!write(*,*)' vv1=',vv1,' vv2=',vv2
				y1=ylevel(ipsgr,nur1)
				y2=ylevel(ipsgr,nur2)
				v000=vv1+((vv2-vv1)/(y2-y1))*(yyy-y1)

	!			write(*,*)' v000=',v000,' iinf=',iinf

				do itop=1,iinf
					!write(*,*)' iuz=',iuz(itop),' nurr=',nurr(itop)
					!pause
					iuz0=iuz(itop)
					nur0=nurr(itop)
					imatr=popor(ipsgr,iuz0,nur0)
					if(imatr.eq.0) pause




					do iotr=1,4
						nnn=nur1
						if(iotr.gt.2) nnn=nur2
						!write(*,*)' iotr4(iotr)=',iotr4(iotr)
						!pause
						ii1=kod_otr(ipsgr,1,iotr4(iotr),nnn)
						!write(*,*)' ii1=',ii1
						x1=xtop(ipsgr,ii1,nnn)
						z1=ztop(ipsgr,ii1,nnn)
						v1=vtop(ips123,ii1,nnn)
						if(ii1.eq.iuz0.and.nnn.eq.nur0) then
							!write(*,*)' in node:',v1,v1*1.02
							v1=v1*1.02
						end if
						ii2=kod_otr(ipsgr,2,iotr4(iotr),nnn)
						x2=xtop(ipsgr,ii2,nnn)
						z2=ztop(ipsgr,ii2,nnn)
						v2=vtop(ips123,ii2,nnn)
						if(ii2.eq.iuz0.and.nnn.eq.nur0) then
							!write(*,*)' in node:',v2,v2*1.02
							v2=v2*1.02
						end if
!if(ips0.eq.2.and.imatr.eq.1333) write(*,*)ii1,' v1=',v1,ii2,' v2=',v2
						votr(iotr)=v1+((v2-v1)/(x2-x1))*(xxx-x1)
						zotr(iotr)=z1+((z2-z1)/(x2-x1))*(xxx-x1)
					end do
if(abs(nrefmod).gt.10) then
	write(*,*)' 4        nrefmod=',nrefmod

	pause
end if
					!pause
					z11=zotr(1)
					z21=zotr(2)
					z12=zotr(3)
					z22=zotr(4)
					v11=votr(1)
					v21=votr(2)
					v12=votr(3)
					v22=votr(4)
!if(ips0.eq.2.and.imatr.eq.1333) write(*,*)' v11=',v11,' v21=',v21
!if(ips0.eq.2.and.imatr.eq.1333) write(*,*)' v12=',v12,' v22=',v22
					vv1=v11+((v21-v11)/(z21-z11))*(zzz-z11)
					vv2=v12+((v22-v12)/(z22-z12))*(zzz-z12)
!if(ips0.eq.2.and.imatr.eq.1333) write(*,*)' vv1=',vv1,' vv2=',vv2
					y1=ylevel(ipsgr,nur1)
					y2=ylevel(ipsgr,nur2)
					vfound=vv1+((vv2-vv1)/(y2-y1))*(yyy-y1)
!if(ips0.eq.2.and.imatr.eq.1333) write(*,*)' vfound=',vfound

					deltav=vfound-v000
					deltat=-deltav*ds/(v000*v000)
!if(ips0.eq.2.and.imatr.eq.1333) write(*,*)' deltat=',deltat,' deltav=',deltav

					dmatr=deltat/(0.02*vaver(itop))


					if(ipsgr.eq.1.and.ips0.eq.2) then
						vpvs=xaver(itop)
						!write(*,*)' xxx=',xxx
						dmatr=dmatr/vpvs
					end if

					if(ipsgr.eq.2.and.ips0.eq.2) then
						vpvs=xaver(itop)
						vvv=vaver(itop)
						!write(*,*)' vpvs=',vpvs,' vvv=',vvv
						dmatr=-dmatr*vvv/vpvs
					end if

					matr(imatr)=matr(imatr)+dmatr


!if(ips0.eq.2.and.imatr.eq.1333) write(*,*)' imatr=',imatr,' dmatr=',dmatr,' matr(imatr)=',matr(imatr)
!if(ips0.eq.2.and.imatr.eq.1333) pause
				end do	! 8 nodes around the current point
			end do		! points on the ray 
write(*,*)' 3 nrefmod=',nrefmod

			nuz=0
			do i=1,nobr(ipsgr)
				if (abs(matr(i)).lt.1.e-10) cycle
				nuz=nuz+1
				muzel(nuz)=i
				matruzel(nuz)=matr(i)
	!write(*,*)' muzel=',muzel(nuz),' m=',matruzel(nuz)
			end do

write(*,*)' 2 nrefmod=',nrefmod

			nonzer=nonzer+nuz
			if(ips0.eq.1) then
				nrp=nrp+1
				nonz_p=nonz_p+nuz
			else
				nrs=nrs+1
				nonz_s=nonz_s+nuz
			end if

			if(mod(nray,1000).eq.0)write(*,'(4i6,f8.3)')nray,nzt,ips0,nuz,res
			write(21,*)nuz,res,ist,ips0,nzt
			write(11) nuz
			!write(*,*)' nuz=',nuz
			if(nuz.ne.0) then
				write(11) (muzel(i),matruzel(i),i=1,nuz)
				muzold=muzel
				amatold=matruzel
				nuzold=nuz
				!do i=1,nuz
					!write(*,*)ips0,muzel(i),matruzel(i)
				!end do
			end if
		end do	! 2 or 1 grids for P and S models
	end do		! phases from one event

	goto 728
729	close(1)
close(2)

close(11)

open(11,file='../../../DATA/'//ar//'/'//md//'/data/numbers'//it//gr//'.dat')
write(11,*)nray,nobr(1),nobr(2),nzt,nonzer
write(11,*)nrp,nonz_p
write(11,*)nrs,nonz_s
close(11)

write(*,*)' nray=',nray,' nzt=',nzt
write(*,*)' nobr=',nobr(1),nobr(2),' nonzer=',nonzer
write(*,*)' nrp=',nrp,' nonz_p=',nonz_p
write(*,*)' nrs=',nrs,' nonz_s=',nonz_s

stop
end
