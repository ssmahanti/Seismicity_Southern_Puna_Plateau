character*8 ar,md,line
character*1 ps,itt,it0,gr
PARAMETER (nkrmax=500)
real xstn(5000),ystn(5000),zstn(5000),statinv(2,1000)

real dt3(500), w_qual(10)
real aaa(500,4),atmp(500,4),bbb(500),btmp(500),xxx(4)
real www(4),vvv(4,4),dttest(500)
real tob_best(500),trf_best(500),dtold(500)

allocatable rays_all(:,:,:),rays_best(:,:,:),nod_all(:),nod_best(:)

real xvert1(20),yvert1(20),xvert2(20),yvert2(20)
character*2 ver
real xmark(200,20),ymark(200,20),smark(200,20)
integer nmark(100)


common/refmod/nrefmod,zref(600),vref(600,2)
common/pi/pi,per
common/ray_param/ds_ini,ds_part_min,val_bend_min,bend_max0

common/loc_param/wgs,res_loc1,res_loc2,dist_limit,n_pwr_dist,ncyc_av,w_P_S_diff
common/krat/nkrat,istkr(500),tobkr(500),ipskr(500),qualkr(500),trfkr(500),ngood(500),alkr(500),diskr(500)

common/ray/ nodes,xray(1000),yray(1000),zray(1000)
common/nkr_max/nnkrmax
common/center/fi0,tet0
common/keys/key_ft1_xy2



nnkrmax=nkrmax
ifreq=10


one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0

r_hor=0.1
r_ver=0.01
r_time=0.1

open(1,file='../../../model.dat')
read(1,'(a8)')ar		! code of the area
read(1,'(a8)')md		! code of the area
read(1,*)iter		! code of the grid
close(1)

write(itt,'(i1)')iter
write(it0,'(i1)')iter-1

write(*,*)' SOURCE LOCATION: ar=',ar,' md=',md,' it=',itt

!******************************************************************
key_ft1_xy2=1
open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
    read(1,'(a8)',end=513)line
    if(line.eq.'GENERAL ') goto 514
end do
513 continue
write(*,*)' cannot find GENERAL INFORMATION in MAJOR_PARAM.DAT!!!'
pause
514 continue
read(1,*)
read(1,*)
read(1,*)
read(1,*)
read(1,*,end=441,err=441)key_ft1_xy2
read(1,*,end=441,err=441)key_true1
441 close(1)
!******************************************************************



i=system('mkdir -p ../../../TMP_files/tmp')
i=system('mkdir -p ../../../TMP_files/loc')

if(key_ft1_xy2.eq.1) then
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
    close(1)
else
    fi0=0; tet0=0
end if


call read_3D_mod_v(ar,md,iter-1)
call read_z_lim(ar,md)
call read_ini_model(ar,md)
call read_topo(ar)



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
write(*,*)nornt

!******************************************************************


open(1,file='../../../DATA/'//ar//'/'//md//'/MAJOR_PARAM.DAT')
do i=1,10000
	read(1,'(a8)',end=583)line
	if(line.eq.'LOC_PARA') goto 584
end do
583 continue
write(*,*)' cannot find LOC_PARAMETERS in MAJOR_PARAM.DAT!!!'
pause
584 continue

read(1,*)	! Parameters for bending:
read(1,*)ds_ini
read(1,*)ds_part_min
read(1,*)val_bend_min
read(1,*)bend_max0
read(1,*)
read(1,*)	! Parameters for location:
read(1,*)dist_limit	!=100
read(1,*)n_pwr_dist	!=1
read(1,*)ncyc_av	!=10
read(1,*)
read(1,*)res_loc1
read(1,*)res_loc2
read(1,*)w_P_S_diff
read(1,*)stepmax
read(1,*)stepmin
read(1,*)
read(1,*)ifreq
close(1)
w_qual=1

call read_vref(ar,md)


! Read the coordinates of the stations
open(2,file='../../../DATA/'//ar//'/'//md//'/data/stat_xy.dat')
i=0
3	i=i+1
	read(2,*,end=4)xstn(i),ystn(i),zstn(i)
	!write(*,*)xstn(i),ystn(i),zstn(i)
	goto 3
4	close(2)
nst=i-1
!write(*,*)' nst=',nst

statinv=0
if(iter.ne.1) then
	do igr=1,nornt

		write(gr,'(i1)')igr
		open(2,file='../../../DATA/'//ar//'/'//md//'/data/stcor_p_'//it0//gr//'.dat')
		do ist=1,nst
			read(2,*,end=332)stcor
			statinv(1,ist) = statinv(1,ist)+stcor
		end do
		close(2)

332		open(2,file='../../../DATA/'//ar//'/'//md//'/data/stcor_s_'//it0//gr//'.dat')
		do ist=1,nst
			read(2,*,end=333)stcor
			statinv(2,ist) = statinv(2,ist)+stcor
		end do
		close(2)
	end do
	statinv = statinv / nornt
333	continue
end if


if(iter.ne.1) then
	do igr=1,nornt
		write(gr,'(i1)')igr
		iun=30+igr
		open(iun,file='../../../DATA/'//ar//'/'//md//'/data/ztcor_'//it0//gr//'.dat')
	end do
end if

!goto 1313

open(1,file='../../../DATA/'//ar//'/'//md//'/data/rays'//it0//'.dat',form='unformatted')

open(11,file='../../../DATA/'//ar//'/'//md//'/data/rays'//itt//'.dat',form='unformatted')
open(14,file='../../../DATA/'//ar//'/'//md//'/data/srces'//itt//'.dat')
open(12,file='../../../TMP_files/tmp/ray_paths_'//itt//'.dat',form='unformatted')
nzt=0
nray=0
dis_tot1=0
dis_tot2=0
ntot=0
err_loc0=0
err_loc=0
21	continue
	if(key_true1.eq.1) read(1,end=22)xtrue,ytrue,ztrue
	read(1,end=22)xini,yini,zini,nkrat

	!write(*,*)xini,yini,zini,nkrat
	dx_corr=0
	dy_corr=0
	dz_corr=0
	dt_corr=0

	if(iter.ne.1) then
		do igr=1,nornt
			iun=30+igr
			read(iun,*)dx,dy,dz,dt
			!write(*,*)igr,dx,dy,dz,dt
			dx_corr=dx_corr+dx
			dy_corr=dy_corr+dy
			dz_corr=dz_corr+dz
			dt_corr=dt_corr+dt
		end do
		dx_corr=dx_corr/nornt
		dy_corr=dy_corr/nornt
		dz_corr=dz_corr/nornt
		dt_corr=dt_corr/nornt
		!write(*,*)' sum:',dx_corr,dy_corr,dz_corr,dt_corr

	end if
	!write(*,*)xzt,yzt,zzt,nkrat

	xzt=xini - dx_corr
	yzt=yini - dy_corr
	zzt=zini - dz_corr


	d_ztr=sqrt(xzt*xzt+yzt*yzt)
	nzt=nzt+1
	!if(zzt.lt.0) zzt=0

        if(key_ft1_xy2.eq.1) then
            call decsf(xzt,yzt,zzt,fi0,tet0,fff,ttt,hhh)
        else
            fff=zxt; ttt=yzt
        end if

	zlim_up=h_lim(fff,ttt)
	if (zzt.le.zlim_up) zzt=zlim_up

	if(nkrat.eq.0) goto 21
	nkr=0
	do ikrat=1,nkrat
		read(1)ips,ist,tobs_old,tref
		!write(*,*)ist,ips,tobs_old,tref
		nray=nray+1
		tobs=tobs_old - dt_corr - statinv(ips,ist)

		istkr(ikrat)=ist
		ipskr(ikrat)=ips
		tobkr(ikrat)=tobs
		trfkr(ikrat)=tref
		dtold(ikrat)=tobs_old-tref
		qualkr(ikrat)=1

	end do

! TEMP !!!!!!!!!!!!!!!!!
!if(nzt.lt.5) goto 21


	!if (d_ztr.gt.d_ztr_max) goto 21

	allocate(rays_all(3,1000,nkrat),rays_best(3,1000,nkrat),nod_all(nkrat),nod_best(nkrat))

	itstep=0
	dstot=0
	dscur=0

	goal_best=0
	step_cur=stepmax
	if(mod(nzt,ifreq).eq.0)write(*,*)xzt,yzt,zzt,nkrat

331	continue
	itstep=itstep+1
	vzt1=velocity(xzt,yzt,zzt,1)
	vzt2=velocity(xzt,yzt,zzt,2)



	nk=0
	ddd1=0
	ddd2=0


	do ikrat=1,nkrat
		ist=istkr(ikrat)
		ips=ipskr(ikrat)
		xst=xstn(ist)
		yst=ystn(ist)
		zst=zstn(ist)
		dshor=sqrt((xst-xzt)*(xst-xzt)+(yst-yzt)*(yst-yzt))
		dsver=abs(zzt-zst)
		dist=sqrt(dshor*dshor+dsver*dsver)
		diskr(ikrat)=dist

		s0=1/vzt1
		if(ips.ne.1) s0=1/vzt2

		tobs=tobkr(ikrat)
		tref=trfkr(ikrat)
		resid=tobs-tref
		!write(*,*)ikrat, ' ips=',ips,' resid=',resid,' dist=',dist
		!write(*,*)xzt,yzt,zzt

		call trace_bending(xzt,yzt,zzt,xst,yst,zst,ips,	tout)
		!write(*,'(5f8.3)')xst,yst,zst,tobs,tout

		ddd1=ddd1+abs(dtold(ikrat))
		ddd2=ddd2+abs(tobs-tout)
		!write(*,*)' tobs=',tobs,' tout=',tout,trfkr(ikrat),' nodes=',nodes

		nod_all(ikrat)=nodes
		do i=1,nodes
			rays_all(1,i,ikrat)=xray(i)
			rays_all(2,i,ikrat)=yray(i)
			rays_all(3,i,ikrat)=zray(i)
		end do

!if(iter.eq.1) then
!call trace_bending(xzt+2,yzt-3,zzt+4,xst,yst,zst,ips,	tobs)
!tobkr(ikrat)=tobs
!end if

		trfkr(ikrat)=tout
		x1=xray(1)
		y1=yray(1)
		z1=zray(1)
		x2=xray(2)
		y2=yray(2)
		z2=zray(2)


		hor=sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1))
		tot=sqrt(hor*hor+(z2-z1)*(z2-z1))
		!write(*,*)' hor=',hor,' tot=',tot

		cosbe=(x2-x1)/hor
		sinbe=(y2-y1)/hor
		!write(*,*)' dx=',x2-x1,' dy=',y2-y1,' dz=',z2-z1

		cosal=(z2-z1)/tot
		sinal=hor/tot

		px=cosbe*sinal*s0
		py=sinbe*sinal*s0
		pz=cosal*s0
		nk=nk+1
		aaa(nk,1)=px
		aaa(nk,2)=py
		aaa(nk,3)=pz
		aaa(nk,4)=1
		bbb(nk)=tobs-tout



		!write(*,*)' ztr:',xzt,yzt,zzt
		!do i=1,nodes
			!write(*,*)xray(i),yray(i),zray(i)
		!end do
		!write(*,*)' sta:',xst,yst,zst
		!pause


		nkr=nkr+1

		dt3(ikrat)=tobs-tout
		
		!write(*,*)ips,dist,' dt=',dt3(ikrat)

	end do
    !pause
	red=100*(ddd1-ddd2)/ddd1
!	write(*,*)' d1=',ddd1/nkrat,' d2=',ddd2/nkrat,' red=',red


	if(nkr.eq.0) goto 21


	do i1=1,nkrat
		bbb(i1)=dt3(i1)
		if(ipskr(i1).ne.2) cycle
		do i2=1,nkrat
			if(i2.eq.i1) cycle
			if(istkr(i1).ne.istkr(i2)) cycle
			if(ipskr(i2).ne.1) then
				if(mod(nzt,ifreq).eq.0)write(*,*)' i1=',i1,' ips1=',ipskr(i1),' i2=',i2,' ips2=',ipskr(i2)
			end if
			ipskr(i1)=3

			dt3(i1)=dt3(i1)-dt3(i2)
			bbb(i1)=dt3(i1)
			do ii=1,4
				aaa(i1,ii)=(aaa(i1,ii)-aaa(i2,ii))
			end do
			exit
		end do
	end do

	call dispers(dt3,	disp3,aver3,nkr3,ank)
!	write(*,*)' ank=',ank



	do i1=1,nkrat
		!write(*,*)' nkrat=',nkrat,' tobkr(nkrat)=',tobkr(nkrat)
		tobkr(i1)=tobkr(i1) -aver3
		dt3(i1)=tobkr(i1) - trfkr(i1)
		ddd=diskr(i1)
		!write(*,*)' i1=',i1,' ddd=',ddd
		if(ddd.lt.dist_limit) then
			wdist = 1
		else
			wdist = (dist_limit/(ddd))**n_pwr_dist
		end if

		ccc=1
		if(ipskr(i1).eq.3) ccc = w_P_S_diff
		if(ipskr(i1).ne.3) bbb(i1) = bbb(i1)-aver3
		do ii=1,4
			aaa(i1,ii)=aaa(i1,ii)*wdist*ccc
		end do
		bbb(i1) = bbb(i1)*wdist*ccc
	end do

	!do i=1,nkrat
		!write(*,*)ipskr(i),' dt=',bbb(i),tobkr(i)-trfkr(i)
	!end do

	atmp=aaa
	btmp=bbb

	nk=0
	aaa=0
	bbb=0
	do ik=1,nkrat
		if(ipskr(ik).eq.3) ipskr(ik)=2
		if(abs(dt3(ik)).gt.res_loc2) cycle
		nk=nk+1
		bbb(nk)=btmp(ik)
		do i4=1,4
			aaa(nk,i4)=atmp(ik,i4)
		end do
		!write(*,*)' ist=',istkr(i),' ips=',ipskr(i)
	end do


	!if(mod(nzt,ifreq).eq.0)write(*,*)itstep,' dscur=',dscur,' red=',red,' ank=',ank
	if(ank.gt.goal_best) then
		x_best=xzt
		y_best=yzt
		z_best=zzt
		tob_best=tobkr
		trf_best=trfkr
		goal_best=ank
		s_best=dstot
		rays_best=rays_all
		nod_best=nod_all
	else
		dscur=dscur/2.
		dxcur=dxcur/2.
		dycur=dycur/2.
		dzcur=dzcur/2.

		xzt=xzt-dxcur
		yzt=yzt-dycur
		zzt=zzt-dzcur

		call decsf(xzt,yzt,zzt,fi0,tet0,fff,ttt,hhh)
		zlim_up=h_lim(fff,ttt)
		if (zzt.le.zlim_up) zzt=zlim_up

		dstot=dstot-dscur
		step_cur=dscur
		if(dscur.gt.stepmin) goto 331

	end if


	do i4=1,4
		nk=nk+1
		reg=r_hor
		if(i4.eq.3)reg=r_ver
		if(i4.eq.4)reg=r_time
		aaa(nk,i4)=reg
	end do

	!do i=1,nk
		!write(*,*)(aaa(i,i4),i4=1,4),' b=',bbb(i)
	!end do


!	xxx(1)=2
!	xxx(2)=-3
!	xxx(3)=5
!	xxx(4)=-1
!	do i=1,nk-4
!		dt=0
!		do i4=1,4
!			dt=dt+aaa(i,i4)*xxx(i4)
!		end do
!		bbb(i)=dt
!	end do

	atmp = aaa
	btmp = bbb
	m=nk
	n=4
	mp=nkrmax
	np=4

    call SVDCMP(aaa,M,N,MP,NP,www,vvv)
    call SVBKSB(aaa,www,vvv,M,N,MP,NP,bbb,xxx)
	dt=xxx(4)
	!write(*,*)' dx=',xxx(1),' dy=',xxx(2),' dz=',xxx(3),' dt=',dt
	disp1=0
	disp2=0
	do i=1,nk-4
		dt=0
		do j=1,4
			dt=dt+atmp(i,j)*xxx(j)
		end do
		disp1=disp1+abs(btmp(i))
		disp2=disp2+abs(btmp(i)-dt)
		!write(*,'(3f8.4)')bbb(i),bbb(i)-dt,dt
	end do
	disp1=disp1/nk
	disp2=disp2/nk
	red=100*(disp1-disp2)/disp1
	!write(*,*)' disp1=',disp1,' disp2=',disp2,' red=',red


	shift0=sqrt(xxx(1)*xxx(1)+xxx(2)*xxx(2)+xxx(3)*xxx(3))
	!write(*,*)' shift0=',shift0

	scale=1.
	if(shift0.gt.step_cur)scale=step_cur/shift0

	dxcur=-xxx(1)*scale
	dycur=-xxx(2)*scale
	dzcur=-xxx(3)*scale

	xnew=xzt+dxcur
	ynew=yzt+dycur
	znew=zzt+dzcur

	call decsf(xnew,ynew,0.,fi0,tet0,fi,tet,h)
	deplim = z_lim(fi,tet)
	
	zlim_up=h_lim(fi,tet)
	if (znew.le.zlim_up) znew=zlim_up


	if(znew.gt.deplim.or.znew.lt.zlim_up) then
		nk=nk-4
		do i=1,nk
			aaa(i,3)=1
		end do
		do i4=1,3
			nk=nk+1
			reg=r_hor
			if(i4.eq.3)reg=r_time
			aaa(nk,i4)=reg
		end do
		atmp = aaa
		btmp = bbb
		m=nk
		n=3
		mp=nkrmax
		np=3

		call SVDCMP(aaa,M,N,MP,NP,www,vvv)
		call SVBKSB(aaa,www,vvv,M,N,MP,NP,bbb,xxx)
		dt=xxx(3)
		!write(*,*)' dx=',xxx(1),' dy=',xxx(2),' dt=',dt
		disp1=0
		disp2=0
		do i=1,nk-3
			dt=0
			do j=1,3
				dt=dt+atmp(i,j)*xxx(j)
			end do
			disp1=disp1+abs(btmp(i))
			disp2=disp2+abs(btmp(i)-dt)
			!write(*,'(3f8.4)')bbb(i),bbb(i)-dt,dt
		end do
		disp1=disp1/(nk-3)
		disp2=disp2/(nk-3)
		red=100*(disp1-disp2)/disp1
		!write(*,*)' disp1=',disp1,' disp2=',disp2,' red=',red

		shift0=sqrt(xxx(1)*xxx(1)+xxx(2)*xxx(2))

		scale=1.
		if(shift0.gt.step_cur)scale=step_cur/shift0

		dxcur=-xxx(1)*scale
		dycur=-xxx(2)*scale
		dzcur=0

		xnew=xzt+dxcur
		ynew=yzt+dycur
		znew=zzt+dzcur
		
	end if

	!write(*,*)' dxcur=',dxcur,' dycur=',dycur,' dzcur=',dzcur
	!pause


	dscur=sqrt(dxcur*dxcur+dycur*dycur+dzcur*dzcur)

	xzt=xnew
	yzt=ynew
	zzt=znew

        if(key_ft1_xy2.eq.1) then
            call decsf(xzt,yzt,zzt,fi0,tet0,fff,ttt,hhh)
        else
            fff=zxt; ttt=yzt
        end if

	zlim_up=h_lim(fff,ttt)
	if (zzt.le.zlim_up) zzt=zlim_up

	dstot=dstot+dscur


	!if(iter.eq.6) stop

	!pause

	if(dscur.gt.stepmin) goto 331

	if(mod(nzt,ifreq).eq.0)write(*,*)x_best,y_best,z_best
	if(key_true1.eq.1) write(11)xtrue,ytrue,ztrue
	write(11)x_best,y_best,z_best,nkrat


        if(key_ft1_xy2.eq.1) then
            call decsf(x_best,y_best,0.,fi0,tet0,fzt,tzt,hhh)
        else
            fzt=x_best; tzt=y_best
        end if

	write(14,*) fzt,tzt,z_best


	disp1=0
	disp2=0
	do i=1,nkrat
		!write(*,*)istkr(i),ipskr(i),' dt=',tob_best(i)-trf_best(i),dtold(i)
		disp1=disp1+abs(dtold(i))
		disp2=disp2+abs(tob_best(i)-trf_best(i))
		dis_tot1=dis_tot1+abs(dtold(i))
		dis_tot2=dis_tot2+abs(tob_best(i)-trf_best(i))
		ntot=ntot+1
		write(11)ipskr(i),istkr(i),tob_best(i),trf_best(i)
		write(12)nod_best(i)
		do inod=1,nod_best(i)
			write(12)(rays_best(i3,inod,i),i3=1,3)
		end do
	end do
	disp1=disp1/nkrat
	disp2=disp2/nkrat
	s_best=sqrt((xini-x_best)**2+(yini-y_best)**2+(zini-z_best)**2)

        dt_aver1=dis_tot1/ntot
        dt_aver2=dis_tot2/ntot
        red=100*(dis_tot1-dis_tot2)/dis_tot1
	if(mod(nzt,ifreq).eq.0)write(*,*)' old resid=',dt_aver1,' new_resid=',dt_aver2,' red=',red
	if(mod(nzt,ifreq).eq.0)write(*,*)nzt,ntot,' ds=',s_best,' G=',goal_best
	if(mod(nzt,ifreq).eq.0)write(*,*)' ********************************************'

	deallocate(rays_all,rays_best,nod_all,nod_best)

        
        if(key_true1.eq.1) then
            err = sqrt ( (xtrue-x_best)**2 + (ytrue-y_best)**2 + (ztrue-z_best)**2 )
            err_loc = err_loc + err
            err0 = sqrt ( (xtrue-xini)**2 + (ytrue-yini)**2 + (ztrue-zini)**2 )
            err_loc0 = err_loc0 + err0
        end if


	!if(nzt.eq.3) stop

	goto 21
22 close(1)

close(11)
close(12)
close(14)


if(key_true1.eq.1) then
    err_loc = err_loc / nzt
    err_loc0 = err_loc0 / nzt
    write(*,*)' err_loc0=',err_loc0,' err_loc=',err_loc
end if

write(*,*)' nzt=',nzt,' nray=',nray

stop
end
