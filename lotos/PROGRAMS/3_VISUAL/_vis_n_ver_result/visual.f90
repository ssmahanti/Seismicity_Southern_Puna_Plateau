character*4 dsaa/'DSAA'/
character*20 scale_line,scale_vpvs,scale,scale_vp,scale_vs

character*256 cmd
character*8 ar,md,line
character*2 lv, ver
character*1 ps ,rm,it
allocatable dvan(:,:),aprio_dv(:,:),vvv(:,:),vtmp(:,:),vabs(:,:),vabsp(:,:)
real hlev(20)
real fia0(100),teta0(100),fib0(100),tetb0(100)
real fmark(200,20),tmark(200,20),smark(200,20)
integer kdot_rgb(3)
integer nmark(100)


common/pi/pi,per
common/center/fi0,tet0
common/keys/key_ft1_xy2

one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0
rz=6371.

w_limit=0.2

open(1,file='../../../model.dat')
read(1,'(a8)')ar
read(1,'(a8)')md
read(1,*)iter		
close(1)
write(it,'(i1)')iter

write(*,*)' ar=',ar,' md=',md,' iter=',iter

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
read(1,*,end=497,err=497)key_ft1_xy2
read(1,*,end=497,err=497)key_true1
497 close(1)
!******************************************************************


i=system('mkdir ../../../TMP_files/vert')
i=system('mkdir -p ../../../PICS/ps/'//ar//'/'//md)
i=system('mkdir -p ../../../PICS/png/'//ar//'/'//md)
i=system('cp ../../../COMMON/gmt/vis_result_gmt.pl ../../../PROGRAMS/3_VISUAL/_vis_n_ver_result/vis_result_gmt.pl')



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

ngr1=1
ngr2=nornt


add_perc=0
kod_av_bias=0
kod_apriori=0
ind_srce=1


!******************************************************************
if(key_ft1_xy2.eq.1) then
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
    fi0=0
    tet0=0
end if
!******************************************************************

ksec_ver=1
kps_ver=1

open(2,file='../../../DATA/'//ar//'/setver.dat')
read(2,*)nver
do ii=1,nver
	read(2,*) fia0(ii),teta0(ii),fib0(ii),tetb0(ii)
end do
read(2,*) dist_from_sec_event
read(2,*) dxsec
read(2,*) zmin,zmax,dzsec
read(2,*) dsmark
read(2,*) dismax
read(2,*) ismth
read(2,*) 
read(2,*,end=551) ksec_ver,kps_ver
read(2,*,end=551) dfmark,dtmark
551 close(2)


write(it,'(i1)')iter


rsmth=ismth+0.5


call read_vref(ar,md)


if(kod_apriori.eq.1) then
	call read_ini_model(ar,md)
end if

call read_topo(ar)

open(2,file='../../../DATA/'//ar//'/sethor.dat')
read(2,*) nlev  
read(2,*) (hlev(i),i=1,nlev)
read(2,*) fmap1,fmap2,dfmap,tmap1,tmap2,dtmap  
close(2)

open(16,file='../../../TMP_files/info_map.txt')
write(16,*)nver
write(16,*)fmap1+fi0,fmap2+fi0
write(16,*)tmap1+tet0,tmap2+tet0


open(433,file='../../../TMP_files/list_ver_p.txt')
open(466,file='../../../TMP_files/list_ver_s.txt')
open(499,file='../../../TMP_files/list_ver_vpvs.txt')


do iver=1,nver
	write(ver,'(i2)')iver

	if(key_ft1_xy2.eq.1) then
		fia=fia0(iver)
		teta=teta0(iver)
		fib=fib0(iver)
		tetb=tetb0(iver)
		call SFDEC(fia,teta,0.,xa,ya,Z,fi0,tet0)
		call SFDEC(fib,tetb,0.,xb,yb,Z,fi0,tet0)
	else
		xa=fia0(iver)
		ya=teta0(iver)
		xb=fib0(iver)
		yb=tetb0(iver)
	end if
	!write(*,*)' xa=',xa,' ya=',ya
	!write(*,*)' xb=',xb,' yb=',yb
	dist=sqrt((xb-xa)*(xb-xa)+(yb-ya)*(yb-ya))

	sinpov=(yb-ya)/dist
	cospov=(xb-xa)/dist
	nxsec=dist/dxsec+1
	dxsec=dist/(nxsec-1)
	nzsec=(zmax-zmin)/dzsec+1
	dzsec=(zmax-zmin)/(nzsec-1)
	write(*,*)' nxsec=',nxsec,' nzsec=',nzsec

	allocate (dvan(nxsec,nzsec),aprio_dv(nxsec,nzsec),vvv(nxsec,nzsec))
	allocate (vtmp(nxsec,nzsec),vabs(nxsec,nzsec),vabsp(nxsec,nzsec))
	vvv=0
	dvan=0


	open(11,file='../../../TMP_files/vert/mark_'//ver//'.dat')
	imark=0
	do sss=0.,dist,dsmark
		x=xa+cospov*sss
		y=ya+sinpov*sss
		if(key_ft1_xy2.eq.1) then
		    call decsf(x,y,0.,fi0,tet0,FI,TET,h)
		else
		    fi=x
		    tet=y
		end if
		write(11,*)fi,tet,sss
		imark=imark+1
		fmark(iver,imark)=fi
		tmark(iver,imark)=tet
		smark(iver,imark)=sss
	end do
	imark=imark+1
	fmark(iver,imark)=fib
	tmark(iver,imark)=tetb
	smark(iver,imark)=dist
	close(11)
	nmark(iver)=imark


	! Draw the position of the section on the surface (line)
	open(11,file='../../../TMP_files/vert/mark_'//ver//'.bln')
	write(11,*) imark
	do i=1,imark
	    write(11,*)fmark(iver,i),tmark(iver,i)	!,smark(i)
	end do
	close(11)

	write(16,*)'mark_',ver,'.bln'

	!Draw topography on the section
	open(11,file='../../../TMP_files/vert/topo_'//ver//'.bln')
	write(11,*)nxsec
	do ix=1,nxsec
		sss=(ix-1)*dxsec
		xcur=xa+((xb-xa)/dist)*sss
		ycur=ya+((yb-ya)/dist)*sss
		if(key_ft1_xy2.eq.1) then
		    call decsf(xcur,ycur,0.,fi0,tet0,fff,ttt,h)
		else
		    fff=xcur
		    ttt=ycur
		end if
		write(11,*)sss,-h_lim(fff,ttt)
	end do
	close(11)



	if(ind_srce.ne.0) then
	! Read the coordinates of the stations
	open(2,file='../../../DATA/'//ar//'/'//md//'/data/stat_xy.dat')
	open(12,file='../../../TMP_files/vert/stat_'//ver//'.dat')
	i=0
	nst1=0
	3	i=i+1
		read(2,*,end=4)xst,yst,zst
		xx1=(xst-xa)*cospov+(yst-ya)*sinpov
		yy1=-(xst-xa)*sinpov+(yst-ya)*cospov
		if(abs(yy1).lt.dist_from_sec_event) then
			nst1=nst1+1
			write(12,*)xx1,-zst
		end if
		goto 3
	4	close(2)
	close(12)



	!open(1,file='../../data/'//ar//'/inidata/events.dat')

	open(1,file='../../../DATA/'//ar//'/'//md//'/data/srces'//it//'.dat')
	open(11,file='../../../TMP_files/vert/ztr_'//ver//'.dat')
	nzt1=0
	nzt=0
	872	read(1,*,end=871)fzt,tzt,zzt
	    if(key_ft1_xy2.eq.1) then
		call SFDEC(fzt,tzt,0.,xzt,yzt,Z,fi0,tet0)
	    else
		xzt=fzt; yzt=tzt
	    end if


	    nzt=nzt+1
	    xx1=(xzt-xa)*cospov+(yzt-ya)*sinpov
	    yy1=-(xzt-xa)*sinpov+(yzt-ya)*cospov


	    if(abs(yy1).lt.dist_from_sec_event) then
		    nzt1=nzt1+1
		    write(11,*)xx1,-zzt,yy1
	    end if
	    goto 872
	871 close(1)
	close(11)
	write(*,*)' nst1=',nst1,' nzt1=',nzt1
	end if

	!************************************************************************
	!************************************************************************
	!************************************************************************
	!************************************************************************
	!************************************************************************
	!************************************************************************
	do ips=1,2
		write(ps,'(i1)')ips
		vvv=0
		dvan=0

		do igr=ngr1,ngr2
			write(*,*)' igr=',igr
			call prepare_model_v(ar,md,ips,iter,igr)

			do ix=1,nxsec
				sss=(ix-1)*dxsec
				!write(*,*)' ix=',ix,' sss=',sss,' dist=',dist
				!sss=500
				!if(mod(ix,10).eq.0)write(*,*)' ix=',ix,' sss=',sss
				xcur=xa+((xb-xa)/dist)*sss
				ycur=ya+((yb-ya)/dist)*sss

				if(key_ft1_xy2.eq.1) then
					call decsf(xcur,ycur,0.,fi0,tet0,fff,ttt,h)
				else
					fff=xcur; ttt=ycur
				end if



				!write(*,*)' xcur=',xcur,' ycur=',ycur
				!write(*,*)' fi=',fff,' tet=',ttt
				do iz=1,nzsec
					zcur=zmin+(iz-1)*dzsec
					vref=vrefmod(zcur,ips)
					if(igr.eq.ngr1) then
					    aprio_dv(ix,iz)=0
					    if(kod_apriori.eq.1) then
						    aprio_dv(ix,iz)=vert_anom(xcur,ycur,zcur,ips)
					    end if
					end if
					!zcur=15
					!write(*,*)' avmoho=',avmoho,' z_moho=',z_moho

					call dv_1_grid_v(fff,ttt,zcur,dismax,   dv,umn)
	
					zlim_up=h_lim(fff,ttt)
					if (zcur.lt.zlim_up) umn=0

					!write(*,*)' zcur=',zcur,' dv=',dv,' umn=',umn
					!pause

					dvan(ix,iz) = dvan(ix,iz) + dv*umn
					vvv(ix,iz)=vvv(ix,iz)+umn
				end do
			end do

		end do



		!***************************************************************
		!***************************************************************
		!***************************************************************

		do iz=nzsec,1,-1
		    do ix=1,nxsec
			vanom=-999
			if(vvv(ix,iz).gt.0.0001) then
				vanom=dvan(ix,iz)/vvv(ix,iz)
			end if
			dvan(ix,iz)=vanom
		    end do
		end do



		! smoothing:
		vtmp=dvan
		do iz=1,nzsec
			do ix=1,nxsec
				dvan(ix,iz)=-999
				if(vvv(ix,iz).lt.0.01) cycle
				vanm=0.
				iv=0
				do ixx=-ismth,ismth
					if (ix+ixx.lt.1) cycle
					if (ix+ixx.gt.nxsec) cycle
					do izz=-ismth,ismth
						if (iz+izz.lt.1) cycle
						if (iz+izz.gt.nzsec) cycle
						if(vvv(ix+ixx,iz+izz).lt.0.01) cycle
						rr=ixx*ixx+izz*izz
						r=sqrt(rr)
						if(r.gt.rsmth) cycle
						iv=iv+1
						vanm=vanm+vtmp(ix+ixx,iz+izz)
					end do
				end do
				dvan(ix,iz)=vanm/iv
			end do
		end do


		aver=0
		naver=0
		do iz=1,nzsec
			zcur=zmin+iz*dzsec
			v0=vrefmod(zcur,ips)
			!write(*,*) 'v0=',v0
			do ix=1,nxsec
				vanom=-999
				vab=-999
				if(vvv(ix,iz).gt.w_limit) then
					vanom=100*dvan(ix,iz)/v0
					dvan(ix,iz)=vanom
					vab=v0*(1+0.01*(vanom+aprio_dv(ix,iz)))
			    !if(ips.eq.2) then
				!write(*,*)' vanom=',vanom,' vab=',vab
				!pause
			    !end if
					aver=aver+vanom
					naver=naver+1
				end if
				vabs(ix,iz)=vab
			end do
		end do
			   !if(ips.eq.2) then
				!write(*,*)((vabs(ix,iz),ix=1,nxsec),iz=1,nzsec)
				!stop
			    !end if

		!pause
		aver=aver/naver
		!dvan=dvan-aver

		if(ips.eq.1) then
			vabsp=vabs
		else
			do iz=1,nzsec
				!zcur=zmin+iz*dzsec
				!write(*,*)' zcur=',zcur
				do ix=1,nxsec
					!sss=(ix-1)*dxsec
					!write(*,*)' sss=',sss
					!write(*,*)' vp=',vabsp(ix,iz),' vs=',vabs(ix,iz),' vp/vs=',vabsp(ix,iz)/vabs(ix,iz)
					if(abs(vabs(ix,iz)).gt.900.or.abs(vabsp(ix,iz)).gt.900) then
						vtmp(ix,iz)=-999
					else
						vtmp(ix,iz)=vabsp(ix,iz)/vabs(ix,iz)
						!write(*,*)' vp=',vabsp(ix,iz),' vs=',vabs(ix,iz),' vp/vs=',vabsp(ix,iz)/vabs(ix,iz)
					end if

					!vabs(ix,iz)=vab
				end do
			end do


			open(14,file='../../../TMP_files/vert/vpvs_'//it//ver//'.xyz')
			do iz=nzsec,1,-1
				zcur=zmin+iz*dzsec
				do ix=1,nxsec
				      sss=(ix-1)*dxsec
				    write(14,*)sss,-zcur,vtmp(ix,iz)
				end do
			end do
		       close(14)



			open(14,file='../../../TMP_files/vert/vpvs_'//it//ver//'.grd')
			write(14,'(a4)')dsaa
			write(14,*)nxsec,nzsec
			write(14,*)0,dist
			write(14,*)-zmax,-zmin
			write(14,*)-9999,999
			do iz=nzsec,1,-1
				write(14,*)(vtmp(ix,iz),ix=1,nxsec)
			end do
			close(14)

			write(499,670)it,ver
			670 format('../../../TMP_files/vert/vpvs_',a1,a2,'.grd')
			write(499,671)ver
			671 format('../../../TMP_files/vert/ztr_',a2,'.dat')
			write(499,536)ver
			536 format('Vp/Vs. Section ',a2)

		
		end if

		open(14,file='../../../TMP_files/vert/anom_'//it//ver//'.xyz')
		open(15,file='../../../TMP_files/vert/abs_'//it//ver//'.xyz')
		do iz=nzsec,1,-1
			zcur=zmin+iz*dzsec
			do ix=1,nxsec
				sss=(ix-1)*dxsec
				write(14,*)sss,-zcur,dvan(ix,iz)+add_perc+aprio_dv(ix,iz)
				write(15,*)sss,-zcur,vabs(ix,iz)
			end do
		end do
		close(14)
		close(15)


		open(14,file='../../../TMP_files/vert/ver_'//ps//it//ver//'.grd')
		write(14,'(a4)')dsaa
		write(14,*)nxsec,nzsec
		write(14,*)0,dist
		write(14,*)-zmax,-zmin
		write(14,*)-9999,999
		do iz=nzsec,1,-1
			write(14,*)(dvan(ix,iz)+add_perc+aprio_dv(ix,iz),ix=1,nxsec)
		end do
		close(14)

		open(14,file='../../../TMP_files/vert/abs_'//ps//it//ver//'.grd')
		write(14,'(a4)')dsaa
		write(14,*)nxsec,nzsec
		write(14,*)0,dist
		write(14,*)-zmax,-zmin
		write(14,*)-9999,999
		do iz=nzsec,1,-1
			write(14,*)(vabs(ix,iz),ix=1,nxsec)
		end do
		close(14)

		if(ips.eq.1) then
			write(433,666)ps,it,ver
			666 format('../../../TMP_files/vert/ver_',a1,a1,a2,'.grd')
			write(433,667)ver
			667 format('../../../TMP_files/vert/ztr_',a2,'.dat')
			write(433,534)ver
		534 format('P anomalies.  Section ',a2)
		else
			write(466,668)ps,it,ver
			668 format('../../../TMP_files/vert/ver_',a1,a1,a2,'.grd')
			write(466,669)ver
			669 format('../../../TMP_files/vert/ztr_',a2,'.dat')
			write(466,535)ver
		535 format('S anomalies. Section ',a2)
		end if


	end do
	close(16)
	deallocate(dvan,aprio_dv,vvv,vtmp,vabs,vabsp)

end do


close(433)
close(466)
close(499)

write(cmd,787)ar,md,iter
787 format('perl ../../../PROGRAMS/3_VISUAL/_vis_n_ver_result/vis_result_gmt.pl ',a8,' ',a8,' ',i1,&
' ','../../../TMP_files/list_hor_p.txt ../../../TMP_files/list_ver_p.txt P')
write(*,'(a200)')cmd
i=system(cmd)


write(cmd,788)ar,md,iter
788 format('perl ../../../PROGRAMS/3_VISUAL/_vis_n_ver_result/vis_result_gmt.pl ''',a8,''' ''',a8,''' ''',i1,&
'''',' ''../../../TMP_files/list_hor_s.txt'' ''../../../TMP_files/list_ver_s.txt'' ''S''')
write(*,'(a200)')cmd
i=system(cmd)


write(cmd,789)ar,md,iter
789 format('perl ../../../PROGRAMS/3_VISUAL/_vis_n_ver_result/vis_result_gmt.pl ''',a8,''' ''',a8,''' ''',i1,&
'''',' ''../../../TMP_files/list_hor_vpvs.txt'' ''../../../TMP_files/list_ver_vpvs.txt'' ''VpVs''')
write(*,'(a200)')cmd
i=system(cmd)




stop
end
