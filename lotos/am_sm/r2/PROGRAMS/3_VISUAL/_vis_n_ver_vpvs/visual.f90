!USE DFPORT


character*4 dsaa/'DSAA'/
character*20 scale_dv,scale_vpvs

character*8 ar,md,line
character*2 ver
character*1 ps ,rm,it
allocatable dvan(:,:),vvv(:,:),vtmp(:,:),vabs(:,:)
allocatable dv_p(:,:),dv_s(:,:),vvv_p(:,:),vvv_s(:,:),dxxx(:,:)
real hlev(20)
real fia0(100),teta0(100),fib0(100),tetb0(100)
real fmark(20),tmark(20),smark(20)

integer kdot_rgb(3)

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

i=system('mkdir ../../../TMP_files/vert')
i=system('mkdir -p ../../../PICS/ps/'//ar//'/'//md)
i=system('mkdir -p ../../../PICS/png/'//ar//'/'//md)
i=system('cp ../../../COMMON/gmt/vis_result_gmt.pl ../../../PROGRAMS/3_VISUAL/_vis_n_ver_result/vis_result_gmt.pl')

call read_vref(ar,md)


key_ft1_xy2=1
key_preview=0
open(1,file='../../../preview_key.txt')
read(1,*,end=771)key_preview
771 close(1)

if(key_preview.ne.0) then
	i=system('mkdir ..\..\..\PICS\'//ar//'\'//md//'\IT'//it)
	open(1,file='../../../data/'//ar//'/config.txt')
	read(1,*) 
	read(1,*) npix_map_x,npix_map_y
	read(1,*) 
	read(1,*) 
	read(1,*) npix_x0,npix_y
	read(1,*)tick_x,tick_y
	read(1,*)
	read(1,*)
	read(1,*)
	read(1,*)
	read(1,*)
	read(1,*)
	read(1,*)scale_dv
	read(1,*)dv_min,dv_max
	read(1,*)scale_vpvs
	read(1,*)vpvs_min,vpvs_max
	close(1)

	i=system('copy ..\..\..\COMMON\visual_exe\visual.exe layers.exe')
	i=system('copy ..\..\..\COMMON\scales_scl\'//scale_dv//' '//scale_dv)
	i=system('copy ..\..\..\COMMON\scales_scl\'//scale_vpvs//' '//scale_vpvs)

end if



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
write(*,*)' AREA : ',ar,' Model=',md

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
read(2,*) ind_srce
close(2)

write(it,'(i1)')iter


rsmth=ismth+0.5

!call read_3D_mod_v(ar,iter)
call read_topo(ar)


do iver=1,nver
	write(ver,'(i2)')iver




	fia=fia0(iver)
	teta=teta0(iver)
	fib=fib0(iver)
	tetb=tetb0(iver)
	call SFDEC(fia,teta,0.,xa,ya,Z,fi0,tet0)
	call SFDEC(fib,tetb,0.,xb,yb,Z,fi0,tet0)
	!write(*,*)' xa=',xa,' ya=',ya
	!write(*,*)' xb=',xb,' yb=',yb
	dist=sqrt((xb-xa)*(xb-xa)+(yb-ya)*(yb-ya))
	npix_x = int(npix_y * dist/(zmax-zmin))
	write(*,*)' section:',ver,' dist=',dist,' npix_x=',npix_x
	sinpov=(yb-ya)/dist
	cospov=(xb-xa)/dist
	nxsec=dist/dxsec+1
	dxsec=dist/(nxsec-1)
	nzsec=(zmax-zmin)/dzsec+1
	dzsec=(zmax-zmin)/(nzsec-1)
	write(*,*)' nxsec=',nxsec,' nzsec=',nzsec

	allocate (dvan(nxsec,nzsec),vvv(nxsec,nzsec),vvv_p(nxsec,nzsec))
	allocate (dv_p(nxsec,nzsec))
	allocate (vtmp(nxsec,nzsec),vabs(nxsec,nzsec))


	open(11,file='../../../TMP_files/vert/mark_'//ver//'.dat')
	imark=0
	do sss=0.,dist,dsmark
		x=xa+cospov*sss
		y=ya+sinpov*sss
		call decsf(x,y,0.,fi0,tet0,FI,TET,h)
		write(11,*)fi,tet,sss
		imark=imark+1
		fmark(imark)=fi
		tmark(imark)=tet
		smark(imark)=sss
	end do
	imark=imark+1
	fmark(imark)=fib
	tmark(imark)=tetb
	smark(imark)=dist
	close(11)

! Draw the position of the section on the surface (line)
	open(11,file='../../../TMP_files/vert/mark_'//ver//'.bln')
	write(11,*) imark
	do i=1,imark
		write(11,*)fmark(i),tmark(i)	!,smark(i)
	end do
	close(11)

	!Draw topography on the section
	open(11,file='../../../TMP_files/vert/topo_'//ver//'.bln')
	write(11,*)nxsec
	do ix=1,nxsec
		sss=(ix-1)*dxsec
		xcur=xa+((xb-xa)/dist)*sss
		ycur=ya+((yb-ya)/dist)*sss
		call decsf(xcur,ycur,0.,fi0,tet0,fff,ttt,h)
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
				write(12,*)xx1,-1
			end if
			goto 3
		4	close(2)
		close(12)

		open(1,file='../../../DATA/'//ar//'/'//md//'/data/srces'//it//'.dat')
		open(2,file='../../../DATA/'//ar//'/'//md//'/data/ztr0.dat')
		open(11,file='../../../TMP_files/vert/ztr_'//ver//'.dat')
		open(12,file='../../../TMP_files/vert/ztr_all.dat')
		open(14,file='../../../TMP_files/vert/ztr_old.dat')
		open(13,file='../../../TMP_files/vert/ztr_shift.bln')
		nzt1=0
		nzt=0
	872	read(1,*,end=871)fzt,tzt,zzt
		read(2,*)fzt0,tzt0,zzt0
		call SFDEC(fzt,tzt,0.,xzt,yzt,Z,fi0,tet0)
		call SFDEC(fzt0,tzt0,0.,xzt0,yzt0,Z,fi0,tet0)
		nzt=nzt+1
		xx1=(xzt-xa)*cospov+(yzt-ya)*sinpov
		yy1=-(xzt-xa)*sinpov+(yzt-ya)*cospov
		xx0=(xzt0-xa)*cospov+(yzt0-ya)*sinpov
		yy0=-(xzt0-xa)*sinpov+(yzt0-ya)*cospov

		if(abs(yy1).lt.20)then
			write(12,*)xx1,-zzt
			write(14,*)xx0,-zzt0
			write(13,*)2
			write(13,*)xx1,-zzt
			write(13,*)xx0,-zzt0
		end if



		if(abs(yy1).lt.dist_from_sec_event) then
			nzt1=nzt1+1
			write(11,*)xx1,-zzt,yy1
		end if
		goto 872
	871 close(1)
		close(11)
		write(*,*)' nst1=',nst1,' nzt1=',nzt1
	end if


	do ips=1,2
		write(ps,'(i1)')ips

		vvv=0
		dvan=0

		do igr=ngr1,ngr2
			if(ips.eq.1) then
				call prepare_model_v(ar,md,ips,iter,igr)
			else if(ips.eq.2) then
				call prepare_model_x(ar,md,iter,igr)
			end if

			do ix=1,nxsec
				sss=(ix-1)*dxsec
				!write(*,*)' ix=',ix,' sss=',sss,' dist=',dist
				!sss=90
				!if(mod(ix,10).eq.0)write(*,*)' ix=',ix,' sss=',sss
				xcur=xa+((xb-xa)/dist)*sss
				ycur=ya+((yb-ya)/dist)*sss
				call decsf(xcur,ycur,0.,fi0,tet0,fff,ttt,h)

				!write(*,*)' xcur=',xcur,' ycur=',ycur
				!write(*,*)' fi=',fff,' tet=',ttt
				do iz=1,nzsec
					zcur=zmin+(iz-1)*dzsec
					!zcur=15

					call dv_1_grid_v(fff,ttt,zcur,dismax,   dv,umn)

					zlim_up=h_lim(fff,ttt)
					if (zcur.lt.zlim_up) umn=0

					if(ips.eq.1) then
						vp0=vrefmod(zcur,1)
						dv=dv*100./vp0
					end if

					dvan(ix,iz)=dvan(ix,iz)+dv*umn
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
				!if(ips.eq.2) write(*,*)' ix=',ix,' iz=',iz,' vanom=',vanom,' vvv=',vvv(ix,iz)
				dvan(ix,iz)=vanom
			end do
			!if(ips.eq.2) pause
		end do


! smoothing: ****************************************
		if(ismth.gt.0) then
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
		end if
!************************************************

		if(ips.eq.1) then
			dv_p=dvan
			vvv_p=vvv
		else
			open(14,file='../../../TMP_files/vert/dVpVs_'//ver//'.grd')
			write(14,'(a4)')dsaa
			write(14,*)nxsec,nzsec
			write(14,*)0,dist
			write(14,*)-zmax,-zmin
			write(14,*)-9999,999
			do iz=nzsec,1,-1
				write(14,*)(dvan(ix,iz),ix=1,nxsec)
			end do
			close(14)
			!write(*,*)' vpvs file is created'

			do iz=1,nzsec
				zcur=zmin+iz*dzsec
				vp0=vrefmod(zcur,1)
				vs0=vrefmod(zcur,2)
				do ix=1,nxsec
					vab=-999
					if(vvv(ix,iz).gt.w_limit) then
						vab=(vp0/vs0)+dvan(ix,iz)
					end if
					vabs(ix,iz)=vab
				end do
			end do

			open(14,file='../../../TMP_files/vert/abs_VpVs_'//ver//'.grd')
			write(14,'(a4)')dsaa
			write(14,*)nxsec,nzsec
			write(14,*)0,dist
			write(14,*)-zmax,-zmin
			write(14,*)-9999,999
			do iz=nzsec,1,-1
				write(14,*)(vabs(ix,iz),ix=1,nxsec)
			end do
			close(14)


if(key_preview.eq.0) goto 442


!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************

if(npix_x0.ne.0) then
	npix_x=npix_x0
else
	npix_x = int(npix_y * dist/(zmax-zmin))
end if
write(*,*)' section:',ver,' dist=',dist,' npix_x=',npix_x



open(14,file='config.txt')
write(14,*)npix_x,npix_y
write(14,*)'_______ Size of the picture in pixels (nx,ny)'
write(14,*)0,dist
write(14,*)'_______ Physical coordinates along X (xmin,xmax)'
write(14,*)-zmax,-zmin
write(14,*)'_______ Physical coordinates along Y (ymin,ymax)'
write(14,*)tick_x,tick_y
write(14,*)'_______ Spacing of ticks on axes (dx,dy)'
write(14,251)ar,md,it,ver
251 format('..\..\..\PICS\',a8,'\',a8,'\IT',a1,'\ver_vpvs',a2,'.png')
write(14,*)'_______ Path of the output picture'
write(14,3531)	iver, iver
3531 format(' Vp/Vs ratio, section=',i1,'A - ',i1,'B')
write(14,*)'_______ Title of the plot on the upper axe'
write(14,*)	1
write(14,*)'_______ Number of layers'

259 format('********************************************')

write(14,259)
write(14,*)	1
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,252)ver
252 format('..\..\..\TMP_files\vert\abs_VpVs_',a2,'.grd')
write(14,*)'_______ Location of the GRD file'
write(14,253)scale_vpvs
253 format(a20)
write(14,*)'_______ Scale for visualization'
write(14,*)	vpvs_min,vpvs_max
write(14,*)'_______ scale diapason'

write(14,259)
write(14,*)	3
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,256)ver
256 format('..\..\..\TMP_files\vert\ztr',a2,'.dat')
write(14,*)'_______ Location of the DAT file'
write(14,*)	1
write(14,*)'_______ Symbol (1: circle, 2: square)'
write(14,*)	4
write(14,*)'_______ Size of dots in pixels'
write(14,*)	250,0,0
write(14,*)'_______ RGB color'
close(14)


i=system('layers.exe')


442		continue


		end if




		aver=0
		naver=0
		do iz=1,nzsec
			zcur=zmin+iz*dzsec
			vp0=vrefmod(zcur,1)
			vs0=vrefmod(zcur,2)
			do ix=1,nxsec
				vanom=-999
				vab=-999
				if(vvv(ix,iz).gt.w_limit.and.vvv_p(ix,iz).gt.w_limit) then
					vanom=dvan(ix,iz)
					if(ips.eq.1) then
						vab=vp0*(1+0.01*vanom)
					else
						vab_p = vp0 * (1+0.01*dv_p(ix,iz))
						vpvs = vp0/vs0 + vanom
						vab = vab_p/vpvs
						vanom=100*(vab-vs0)/vs0
						dvan(ix,iz)=vanom
					end if
					aver=aver+vanom
					naver=naver+1
				end if
				vabs(ix,iz)=vab
			end do
		end do
		!pause
		aver=aver/naver
		dvan=dvan-aver
		write(*,*)' ips=',ips,' aver=',aver

		open(14,file='../../../TMP_files/vert/ver_'//ps//it//ver//'.grd')
		write(14,'(a4)')dsaa
		write(14,*)nxsec,nzsec
		write(14,*)0,dist
		write(14,*)-zmax,-zmin
		write(14,*)-9999,999
		do iz=nzsec,1,-1
			write(14,*)(dvan(ix,iz)+add_perc,ix=1,nxsec)
		end do
		close(14)

		open(14,file='../../../TMP_files/vert/abs_'//ps//ver//'.grd')
		write(14,'(a4)')dsaa
		write(14,*)nxsec,nzsec
		write(14,*)0,dist
		write(14,*)-zmax,-zmin
		write(14,*)-9999,999
		do iz=nzsec,1,-1
			write(14,*)(vabs(ix,iz),ix=1,nxsec)
		end do
		close(14)

		if(key_preview.eq.0) goto 441


!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************

if(npix_x0.ne.0) then
	npix_x=npix_x0
else
	npix_x = int(npix_y * dist/(zmax-zmin))
end if
write(*,*)' section:',ver,' dist=',dist,' npix_x=',npix_x


open(14,file='config.txt')
write(14,*)npix_x,npix_y
write(14,*)'_______ Size of the picture in pixels (nx,ny)'
write(14,*)0,dist
write(14,*)'_______ Physical coordinates along X (xmin,xmax)'
write(14,*)-zmax,-zmin
write(14,*)'_______ Physical coordinates along Y (ymin,ymax)'
write(14,*)tick_x,tick_y
write(14,*)'_______ Spacing of ticks on axes (dx,dy)'

write(14,51)ar,md,it,ps,ver
51 format('..\..\..\PICS\',a8,'\',a8,'\IT',a1,'\ver_dv',a1,a2,'.png')

write(14,*)'_______ Path of the output picture'
if(ips.eq.1) then
	write(14,3431)	iver, iver
3431 format(' P anomalies, section=',i1,'A - ',i1,'B')
else
	write(14,3432)	iver,iver
3432 format(' S anomalies, section=',i1,'A - ',i1,'B')
end if
write(14,*)'_______ Title of the plot on the upper axe'
write(14,*)	1
write(14,*)'_______ Number of layers'

59 format('********************************************')

write(14,59)
write(14,*)	1
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,52)ps,it,ver
52 format('..\..\..\TMP_files\vert\ver_',a1,a1,a2,'.grd')
write(14,*)'_______ Location of the GRD file'
write(14,53)scale_dv
53 format(a20)
write(14,*)'_______ Scale for visualization'
write(14,*)	dv_min,dv_max
write(14,*)'_______ scale diapason'

write(14,59)
write(14,*)	3
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,56)ver
56 format('..\..\..\TMP_files\vert\ztr',a2,'.dat')
write(14,*)'_______ Location of the DAT file'
write(14,*)	1
write(14,*)'_______ Symbol (1: circle, 2: square)'
write(14,*)	4
write(14,*)'_______ Size of dots in pixels'
write(14,*)	250,0,0
write(14,*)'_______ RGB color'

close(14)


i=system('layers.exe')


441		continue



	end do

	deallocate(dvan,vvv,vtmp,vabs,dv_p,vvv_p)

end do

stop
end