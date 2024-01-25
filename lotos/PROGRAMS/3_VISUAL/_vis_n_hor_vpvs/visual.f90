!USE DFPORT

character*4 dsaa/'DSAA'/
character*8 ar,md,line
character*2 lv
character*1 ps ,it
character*20 scale_line,scale_line2
allocatable dvan(:,:),vvv(:,:),vtmp(:,:),dv_p(:,:),vvv_p(:,:)
real hlev(20),add_perc(20)
real fzzt(10000,100),tzzt(10000,100),zzzt(10000,100)
integer nzzt(100),line1_rgb(3),line2_rgb(3),kdot_rgb(3)


common/pi/pi,per
common/center/fi0,tet0
common/refmod/nrefmod,hmod(600),vmodp(600),vmods(600)
common/keys/key_ft1_xy2
one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0
rz=6371.

w_limit=0.2

igr=1



open(1,file='../../../model.dat')
read(1,'(a8)')ar
read(1,'(a8)')md
read(1,*)iter		
close(1)
write(it,'(i1)')iter

key_preview=0
open(1,file='../../../preview_key.txt')
read(1,*,end=791)key_preview
791 close(1)

i=system('mkdir -p ../../../TMP_files/hor')
i=system('mkdir -p ../../../PICS/ps/'//ar//'/'//md)
i=system('mkdir -p ../../../PICS/png/'//ar//'/'//md)
!i=system('cp ../../../COMMON/gmt/vis_hor.pl ../_vis_n_hor_result/vis_hor.pl')

!
!******************************************************************
key_ft1_xy2=1
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


write(*,*)' AREA : ',ar, ' model=',md, ' iteration:',iter

!**************************************************************
open(2,file='../../../DATA/'//ar//'/sethor.dat')
read(2,*) nlev  
read(2,*) (hlev(i),i=1,nlev)  
!read(2,*) (add_perc(i),i=1,nlev)
read(2,*) fmap1,fmap2,dfmap,tmap1,tmap2,dtmap  
read(2,*) smaxx
read(2,*) ismth
close(2)


rsmth=ismth+0.5
nfmap=int_best((fmap2-fmap1)/dfmap+1.)
ntmap=int_best((tmap2-tmap1)/dtmap+1.)
write(*,*)' nfmap=',nfmap,' ntmap=',ntmap
allocate(dvan(nfmap,ntmap),vvv(nfmap,ntmap),vtmp(nfmap,ntmap),dv_p(nfmap,ntmap),vvv_p(nfmap,ntmap))


!call read_3D_mod_v(ar,iter-1)

call read_topo(ar)


! Read the values of the reference model
open(1,file='../../../DATA/'//ar//'/'//md//'/data/refmod.dat')
read(1,*,end=81)vpvs
i=0
82	i=i+1
	read(1,*,end=81)hmod(i),vmodp(i),vs
	if(vpvs.lt.0.000001) then
		vmods(i)=vs
	else
		vmods(i)=vmodp(i)/vpvs
	end if
	!write(*,*)hmod(i),vmodp(i),vmods(i)
goto 82
81	close(1)
nrefmod=i-1
!write(*,*)' nrefmod=',nrefmod

!ntmap=1
!nfmap=1


if(ind_srce.ne.0) then
	nzzt=0
	nzt=0
	open(1,file='../../../DATA/'//ar//'/'//md//'/data/srces'//it//'.dat')
	872	read(1,*,end=871)fzt,tzt,zzt
	!call decsf(xzt,yzt,0.,fi0,tet0,fzt,tzt,h)
	nzt=nzt+1
	do ilev=1,nlev
		if(ilev.eq.1) then
			z1=-10
			z2=(hlev(1)+hlev(2))/2
		else if(ilev.eq.nlev) then
			z1=(hlev(nlev-1)+hlev(nlev))/2
			z2=hlev(nlev) + (hlev(nlev)-hlev(nlev-1))/2
		else 
			z1=(hlev(ilev-1)+hlev(ilev))/2
			z2=(hlev(ilev+1)+hlev(ilev))/2
		end if
		if((zzt-z1)*(zzt-z2).le.0) goto 995
	end do
	goto 872

995 continue
	!write(*,*)' zzt=',zzt,' ilev=',ilev,' z1=',z1,' z2=',z2
	nzzt(ilev)=nzzt(ilev)+1
	fzzt(nzzt(ilev),ilev)=fzt
	tzzt(nzzt(ilev),ilev)=tzt
	zzzt(nzzt(ilev),ilev)=zzt

	goto 872
871 close(1)
	DO ilev=1,nlev
		write(lv,'(i2)')ilev
		open(11,file='../../../TMP_files/hor/ztr'//lv//'.dat')
		write(*,*)' ilev=',ilev,' nzzt=',nzzt(ilev)
		do izzt=1,nzzt(ilev)
			write(11,*)fzzt(izzt,ilev),tzzt(izzt,ilev),zzzt(izzt,ilev)
		end do
		close(11)
	end do
end if


!Edited by ssm
!nlev=1
DO ilev=1,nlev
	zzz=hlev(ilev)
	vp0=vrefmod(zzz,1)
	vs0=vrefmod(zzz,2)
	vpvs0=vp0/vs0
	!write(*,*)' vpvs0=',vpvs0
	do iiips=1,2
		write(ps,'(i1)')iiips
		dvan=0
		vvv=0
		!~zzz=15
		write(lv,'(i2)')ilev
		write(*,*)' ilev=',ilev,' zzz=',zzz
		do igr=ngr1,ngr2
			if(iiips.eq.1) then
				call prepare_model_v(ar,md,iiips,iter,igr)
			else if(iiips.eq.2) then
				call prepare_model_x(ar,md,iter,igr)
			end if
			do itet=1,ntmap
				ttt=(itet-1)*dtmap+tmap1+tet0
				!write(*,*)' itet=',itet,' ttt=',ttt
				!ttt=-7.50427449772
				
				do ifi=1,nfmap
					fff=(ifi-1)*dfmap+fmap1+fi0
					!fff=fi0+1

!fff=98.689299034 
!ttt=2.40240317501					!fff=110.808672267
					dv=0
					www=0
					!write(*,*) fff,ttt,zzz,smaxx,dv,www
					call dv_1_grid_v(fff,ttt,zzz,smaxx, dv,www)
					!write(*,*)ilev,fff,ttt,zzz,' dv=',dv,' www=',www
					!pause
					zlim_up=h_lim(fff,ttt)
					if (zzz.lt.zlim_up) www=0

					if(iiips.eq.1) dv=dv*100./vp0
					dvan(ifi,itet)=dvan(ifi,itet)+dv*www
					vvv(ifi,itet)=vvv(ifi,itet)+www
					!if(itet.eq.101) write(*,*)dv,www
				end do
			end do
		end do

		do ifi=1,nfmap
			do itet=1,ntmap
				vanm=-999.
				if (vvv(ifi,itet).gt.w_limit) then
					vanm=dvan(ifi,itet)/vvv(ifi,itet)
				end if
				vtmp(ifi,itet)=vanm
			end do
		end do
		dvan=vtmp
		

		if(ismth.gt.0) then
			do ifi=1,nfmap
				do itet=1,ntmap
					if(vvv(ifi,itet).lt.w_limit) cycle
					vanm=0.
					iv=0
					do iff=-ismth,ismth
						if (ifi+iff.lt.1) cycle
						if (ifi+iff.gt.nfmap) cycle
						do itt=-ismth,ismth
							if (itet+itt.lt.1) cycle
							if (itet+itt.gt.ntmap) cycle
							if(vvv(ifi+iff,itet+itt).lt.w_limit) cycle
							rr=iff*iff+itt*itt
							r=sqrt(rr)
							if(r.gt.rsmth) cycle
							iv=iv+1
							vanm=vanm+dvan(ifi+iff,itet+itt)
						end do
					end do
					vtmp(ifi,itet)=vanm/iv
				end do
			end do
			dvan=vtmp
		end if

		aver=0
		naver=0
		do ifi=1,nfmap
			do itet=1,ntmap
				if(vvv(ifi,itet).gt.w_limit) then
					aver=aver+dvan(ifi,itet)
					naver=naver+1
				end if
				vtmp(ifi,itet)=vanom
				if(kod_apriori.eq.1) then
					ttt=(itet-1)*dtmap+tmap1+tet0
					fff=(ifi-1)*dfmap+fmap1+fi0

                                    if(key_ft1_xy2.eq.1) then
                                        call SFDEC(fff,ttt,0.,xxx,yyy,Z,fi0,tet0)
                                    else
                                        xxx=fff
                                        yyy=ttt
                                    end if

					dv_aprio = vert_anom(xxx,yyy,zzz,ips)
					vtmp(ifi,itet)=vtmp(ifi,itet)+dv_aprio
				end if
				!if(itet.eq.101) write(*,*)vanom,vvv(ifi,itet)
			end do
		end do
		if(naver.gt.0) then
			aver=aver/naver
		end if

		if(iiips.eq.1) then
			dv_p=dvan
			vvv_p=vvv
			dvan=dvan-aver
		end if






		if(iiips.eq.1) then


			open(14,file='../../../TMP_files/hor/dv1'//it//lv//'.grd')
			do ifi=1,nfmap
				do itet=1,ntmap
					if(abs(dvan(ifi,itet)).gt.900) dvan(ifi,itet)=-999 
				end do
			end do
			write(14,'(a4)')dsaa
			write(14,*)nfmap,ntmap
			write(14,*)fmap1+fi0,fmap2+fi0
			write(14,*)tmap1+tet0,tmap2+tet0
			write(14,*)-999,999
			do itet=1,ntmap
				write(14,*)(dvan(ifi,itet),ifi=1,nfmap)
			end do
			close(14)

		else if(iiips.eq.2) then


			do ifi=1,nfmap
				do itet=1,ntmap
					vtmp(ifi,itet)=dvan(ifi,itet)+vpvs0
					if(abs(vtmp(ifi,itet)).gt.900) vtmp(ifi,itet)=-999 
				end do
			end do


			open(14,file='../../../TMP_files/hor/abs_vpvs_'//lv//'.grd')
			write(14,'(a4)')dsaa
			write(14,*)nfmap,ntmap
			write(14,*)fmap1+fi0,fmap2+fi0
			write(14,*)tmap1+tet0,tmap2+tet0
			write(14,*)-999,999
			do itet=1,ntmap
				write(14,*)(vtmp(ifi,itet),ifi=1,nfmap)
			end do
			close(14)


if(key_preview.eq.0) goto 723


!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************

open(14,file='config.txt')
write(14,*)npix_x,npix_y
write(14,*)'_______ Size of the picture in pixels (nx,ny)'
write(14,*)fmap1+fi0,fmap2+fi0
write(14,*)'_______ Physical coordinates along X (xmin,xmax)'
write(14,*)tmap1+tet0,tmap2+tet0
write(14,*)'_______ Physical coordinates along Y (ymin,ymax)'
write(14,*)tick_x,tick_y
write(14,*)'_______ Spacing of ticks on axes (dx,dy)'
write(14,51)ar,md,it,lv
51 format('..\..\..\PICS\',a8,'\',a8,'\IT',a1,'\hor_vpvs',a2,'.png')
write(14,*)'_______ Path of the output picture'
izzz=zzz
write(14,3531)	izzz
3531 format(' Vp/Vs ratio, depth=',i3,' km')
write(14,*)'_______ Title of the plot on the upper axe'
write(14,*)	1
write(14,*)'_______ Number of layers'

59 format('********************************************')

write(14,59)
write(14,*)	1
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,52)lv
52 format('..\..\..\TMP_files\hor\abs_vpvs_',a2,'.grd')
write(14,*)'_______ Location of the GRD file'
write(14,53)scale_line2
53 format(a20)
write(14,*)'_______ Scale for visualization'
write(14,*)	vpvs_min,vpvs_max
write(14,*)'_______ scale diapason'


open(1,file='../../../DATA/'//ar//'/map/polit_bound.bln',status='old',err=491)
close(1)
write(14,59)
write(14,*)	2
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,54)ar
54 format('..\..\..\DATA\',a8,'\map\polit_bound.bln')
write(14,*)'_______ Location of the BLN file'
write(14,*)	3
write(14,*)'_______ Thickness of line in pixels'
write(14,*)	100,0,0
write(14,*)'_______ RGB color'
491 continue


open(1,file='../../../DATA/'//ar//'/map/coastal_line.bln',status='old',err=492)
close(1)
write(14,59)
write(14,*)	2
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,55)ar
55 format('..\..\..\DATA\',a8,'\map\coastal_line.bln')
write(14,*)'_______ Location of the BLN file'
write(14,*)	3
write(14,*)'_______ Thickness of line in pixels'
write(14,*)	0,0,0
write(14,*)'_______ RGB color'
492 continue


write(14,59)
write(14,*)	3
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,56)lv
56 format('..\..\..\TMP_files\hor\ztr',a2,'.dat')
write(14,*)'_______ Location of the DAT file'
write(14,*)	1
write(14,*)'_______ Symbol (1: circle, 2: square)'
write(14,*)	5
write(14,*)'_______ Size of dots in pixels'
write(14,*)	250,0,0
write(14,*)'_______ RGB color'

close(14)

i=system('layers.exe')
723	continue


			open(14,file='../../../TMP_files/hor/vpvs_'//lv//'.grd')
			do ifi=1,nfmap
				do itet=1,ntmap
					if(abs(dvan(ifi,itet)).gt.900) dvan(ifi,itet)=-999 
				end do
			end do
			write(14,'(a4)')dsaa
			write(14,*)nfmap,ntmap
			write(14,*)fmap1+fi0,fmap2+fi0
			write(14,*)tmap1+tet0,tmap2+tet0
			write(14,*)-999,999
			do itet=1,ntmap
				write(14,*)(dvan(ifi,itet),ifi=1,nfmap)
			end do
			close(14)





			aver=0
			naver=0
			do ifi=1,nfmap
				do itet=1,ntmap
					vanm=-999.
					if (vvv(ifi,itet).lt.w_limit) goto 771
					if (vvv_p(ifi,itet).lt.w_limit) goto 771

					vp = ( dv_p(ifi,itet)/100. + 1.) * vp0
					vpvs= vpvs0+dvan(ifi,itet)
					vs=vp/vpvs
					!write(*,*)' vp=',vp,' vpvs=',vpvs,' vs=',vs
					!write(*,*)' vp0=',vp0,' vpvs0=',vpvs0,' vs0=',vs0
					!write(*,*)' dvp=',100*(vp-vp0)/vp0,' dvs=',100*(vs-vs0)/vs0
					vanm=100.*(vs-vs0)/vs0
					aver=aver+vanm
					naver=naver+1

771					vtmp(ifi,itet)=vanm
				end do
			end do
			aver=aver/naver
			dvan=vtmp	!-aver

			open(14,file='../../../TMP_files/hor/dv2'//it//lv//'.grd')
			write(14,'(a4)')dsaa
			write(14,*)nfmap,ntmap
			write(14,*)fmap1+fi0,fmap2+fi0
			write(14,*)tmap1+tet0,tmap2+tet0
			write(14,*)-999,999
			do itet=1,ntmap
				write(14,*)(dvan(ifi,itet),ifi=1,nfmap)
			end do
			close(14)
		end if

!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
!*********************************************************
if(key_preview.eq.0) goto 724

open(14,file='config.txt')
write(14,*)npix_x,npix_y
write(14,*)'_______ Size of the picture in pixels (nx,ny)'
write(14,*)fmap1+fi0,fmap2+fi0
write(14,*)'_______ Physical coordinates along X (xmin,xmax)'
write(14,*)tmap1+tet0,tmap2+tet0
write(14,*)'_______ Physical coordinates along Y (ymin,ymax)'
write(14,*)tick_x,tick_y
write(14,*)'_______ Spacing of ticks on axes (dx,dy)'


write(14,251)ar,md,it,ps,lv
251 format('..\..\..\PICS\',a8,'\',a8,'\IT',a1,'\hor_dv',a1,a2,'.png')

write(14,*)'_______ Path of the output picture'
izzz=zzz
if(iiips.eq.1) then
	write(14,3331)	izzz
3331 format(' P anomalies, depth=',i3,' km')
else
	write(14,3332)	izzz
3332 format(' S anomalies, depth=',i3,' km')
end if
write(14,*)'_______ Title of the plot on the upper axe'
write(14,*)	1
write(14,*)'_______ Number of layers'

259 format('********************************************')

write(14,259)
write(14,*)	1
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,252)ps,it,lv
252 format('..\..\..\TMP_files\hor\dv',a1,a1,a2,'.grd')
write(14,*)'_______ Location of the GRD file'
write(14,253)scale_line
253 format(a20)
write(14,*)'_______ Scale for visualization'
write(14,*)	dv_min,dv_max
write(14,*)'_______ scale diapason'


open(1,file='../../../DATA/'//ar//'/map/polit_bound.bln',status='old',err=481)
close(1)
write(14,59)
write(14,*)	2
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,54)ar
write(14,*)'_______ Location of the BLN file'
write(14,*)	3
write(14,*)'_______ Thickness of line in pixels'
write(14,*)	100,0,0
write(14,*)'_______ RGB color'
481 continue


open(1,file='../../../DATA/'//ar//'/map/coastal_line.bln',status='old',err=482)
close(1)
write(14,59)
write(14,*)	2
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,55)ar
write(14,*)'_______ Location of the BLN file'
write(14,*)	3
write(14,*)'_______ Thickness of line in pixels'
write(14,*)	0,0,0
write(14,*)'_______ RGB color'
482 continue


write(14,259)
write(14,*)	3
write(14,*)'_______ Key of the layer (1: contour, 2: line, 3:dots)'
write(14,256)lv
256 format('..\..\..\TMP_files\hor\ztr',a2,'.dat')
write(14,*)'_______ Location of the DAT file'
write(14,*)	1
write(14,*)'_______ Symbol (1: circle, 2: square)'
write(14,*)	5
write(14,*)'_______ Size of dots in pixels'
write(14,*)	250,0,0
write(14,*)'_______ RGB color'

close(14)


i=system('layers.exe')
724 continue


	end do
end do

stop
end