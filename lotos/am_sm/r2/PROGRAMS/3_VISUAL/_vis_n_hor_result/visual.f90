! HORIZONTAL !!!
! NODES !!!!!!!

character*4 dsaa/'DSAA'/
character*8 ar,md,line
character*2 lv
character*1 ps ,rm,it
character*20 scale_line, scale_line2

character*80 grd_in,ps_out
character*50 title
character*256 cmd




allocatable dvan(:,:),vvv(:,:),v1tmp(:,:),v2tmp(:,:),vabs(:,:,:)
real hlev(20)
integer nrps(2)
real fzzt(10000,100),tzzt(10000,100),zzzt(10000,100)
integer nzzt(100),line1_rgb(3),line2_rgb(3),kdot_rgb(3)
integer*2 izzz

common/pi/pi,per
common/center/fi0,tet0
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

i=system('mkdir -p ../../../TMP_files/hor')
i=system('mkdir -p ../../../PICS/ps/'//ar//'/'//md)
i=system('mkdir -p ../../../PICS/png/'//ar//'/'//md)
!i=system('cp ../../../COMMON/gmt/vis_hor.pl ../_vis_n_hor_result/vis_hor.pl')


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
441 close(1)
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


kod_av_bias=0
kod_apriori=0
ind_srce=1


write(*,*)' ar=',ar,' md=',md
write(it,'(i1)')iter

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

open(2,file='../../../DATA/'//ar//'/sethor.dat')
read(2,*) nlev  
read(2,*) (hlev(i),i=1,nlev)  
read(2,*) fmap1,fmap2,dfmap,tmap1,tmap2,dtmap  
read(2,*) smaxx
read(2,*) ismth
close(2)

if(npix_x0.ne.0) then
    npix_x=npix_x0
else
    npix_x=int(npix_y0*((fmap2-fmap1)/(tmap2-tmap1)))
    npix_y=npix_y0
end if

if(npix_y0.ne.0) then
    npix_y=npix_y0
else
    npix_y=int(npix_x0*((tmap2-tmap1)/(fmap2-fmap1)))
    npix_x=npix_x0
end if

write(*,*)' npix_x=',npix_x,' npix_y=',npix_y


if(kod_apriori.eq.1) then
	call read_ini_model(ar,md)
end if

call read_topo(ar)

rsmth=ismth+0.5
nfmap=int_best((fmap2-fmap1)/dfmap+1.)
ntmap=int_best((tmap2-tmap1)/dtmap+1.)
write(*,*)' nfmap=',nfmap,' ntmap=',ntmap
allocate(dvan(nfmap,ntmap),vvv(nfmap,ntmap),v1tmp(nfmap,ntmap),v2tmp(nfmap,ntmap))
allocate(vabs(2,nfmap,ntmap))


!call read_3D_mod_v(ar,iter-1)

call read_vref(ar,md)


open(1,file='../../../DATA/'//ar//'/'//md//'/data/numray1.dat')
read(1,*) nrps(1),nrps(2)
close(1)


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


open(433,file='../../../TMP_files/list_hor_p.txt')
open(466,file='../../../TMP_files/list_hor_s.txt')
open(499,file='../../../TMP_files/list_hor_vpvs.txt')
!edited by ssm
!nlev=1
DO ilev=1,nlev
	zzz=hlev(ilev)
	write(lv,'(i2)')ilev
	write(*,*)' ilev=',ilev,' zzz=',zzz
	do ips=1,2
		v0=vrefmod(zzz,ips)
		!write(*,*)'vo=',v0
		if(nrps(ips).eq.0) cycle
		write(ps,'(i1)')ips
		dvan=0
		vvv=0
		do igr=ngr1,ngr2
			call prepare_model_v(ar,md,ips,iter,igr)

			do itet=1,ntmap
				ttt=(itet-1)*dtmap+tmap1+tet0
				!write(*,*)' itet=',itet,' ttt=',ttt
				!ttt=-7.45
				do ifi=1,nfmap
					fff=(ifi-1)*dfmap+fmap1+fi0
					!fff=fi0+1
					!fff=110.87
					dv=0
					www=0
					!write(*,*) fff,ttt,zzz,smaxx, dv,www

					call dv_1_grid_v(fff,ttt,zzz,smaxx,dv,www)
					zlim_up=h_lim(fff,ttt)
					if (zzz.lt.zlim_up) www=0
					!write(*,*)ilev,fff,ttt,zzz,' dv=',dv,' www=',www
					dvproc=100*dv/v0
					dvan(ifi,itet)=dvan(ifi,itet)+dvproc*www
					vvv(ifi,itet)=vvv(ifi,itet)+www
					!if(itet.eq.101) write(*,*)dv,www
				end do
			end do
		end do

		do ifi=1,nfmap
			do itet=1,ntmap
				vanm=-999.
				vabs(ips,ifi,itet)=-999
				if (vvv(ifi,itet).gt.w_limit) then
					vanm=dvan(ifi,itet)/vvv(ifi,itet)
					vabs(ips,ifi,itet)=v0*(1+0.01*vanm)
				end if
				v1tmp(ifi,itet)=vanm
			end do
		end do

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
						vanm=vanm+v1tmp(ifi+iff,itet+itt)
					end do
				end do
				v2tmp(ifi,itet)=vanm/iv
			end do
		end do

		aver=0
		naver=0
		do ifi=1,nfmap
			do itet=1,ntmap
				vanom=-999
				if(vvv(ifi,itet).gt.w_limit) then
					vanom=v2tmp(ifi,itet)
					aver=aver+vanom
					naver=naver+1
				end if
				v2tmp(ifi,itet)=vanom
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
					v2tmp(ifi,itet)=v2tmp(ifi,itet)+dv_aprio
				end if
				!if(itet.eq.101) write(*,*)vanom,vvv(ifi,itet)
			end do
		end do
		!pause
		if(naver.gt.0) then
			aver=aver/naver
		end if
		if(kod_av_bias.eq.1) v2tmp=v2tmp-aver


                open(14,file='../../../TMP_files/hor/dv'//ps//it//lv//'.xyz')
                do ifi=1,nfmap
                    fff=(ifi-1)*dfmap+fmap1+fi0
                    do itet=1,ntmap
                        ttt=(itet-1)*dtmap+tmap1+tet0
                        write(14,*)fff,ttt,v2tmp(ifi,itet)
                    end do
                end do
                close(14)


		open(14,file='../../../TMP_files/hor/dv'//ps//it//lv//'.grd')
		write(14,'(a4)')dsaa
		write(14,*)nfmap,ntmap
		write(14,*)fmap1+fi0,fmap2+fi0
		write(14,*)tmap1+tet0,tmap2+tet0
		write(14,*)-999,999
		do itet=1,ntmap
			write(14,*)(v2tmp(ifi,itet),ifi=1,nfmap)
		end do
		close(14)




!*********************************************************
!*********************************************************
!*********************************************************
!******Linux Visualization using GMT *********************
!*********************************************************
!*********************************************************
!*********************************************************

izzz=zzz
if(ips.eq.1) then
	write(433,666)ps,it,lv
	666 format('../../../TMP_files/hor/dv',a1,a1,a2,'.grd')
	write(433,667)lv
	667 format('../../../TMP_files/hor/ztr',a2,'.dat')
	write(433,534)izzz
534 format('P anomalies, depth=',i3,' km')
else
	write(466,668)ps,it,lv
	668 format('../../../TMP_files/hor/dv',a1,a1,a2,'.grd')
	write(466,669)lv
	669 format('../../../TMP_files/hor/ztr',a2,'.dat')
	write(466,535)izzz
535 format('S anomalies, depth=',i3,' km')
end if


!write(*,*)cmd
!i = system(cmd)

!write(*,*)'Creating png...'
!write(cmd,537)ar,md,ps,it,lv,ar,md,ps,it,lv
!537 format('convert -density 100 -geometry 100% -rotate 90 ''../../../PICS/ps/',a8,'/',a8,'/hor_dv',a1,a1,a2,&
!'.ps'' ''../../../PICS/png/',a8,'/',a8,'/hor_dv',a1,a1,a2,'.png''')
!write(*,*)cmd
!i = system(cmd)










	end do

	v1tmp=-999
	do ifi=1,nfmap
		do itet=1,ntmap
			if (abs(vabs(1,ifi,itet)).gt.900..or.abs(vabs(2,ifi,itet)).gt.900.) cycle
			vpvs=vabs(1,ifi,itet)/vabs(2,ifi,itet)
			v1tmp(ifi,itet)=vpvs
		end do
	end do

        open(14,file='../../../TMP_files/hor/vpvs'//it//lv//'.xyz')
        do ifi=1,nfmap
            fff=(ifi-1)*dfmap+fmap1+fi0
            do itet=1,ntmap
                ttt=(itet-1)*dtmap+tmap1+tet0
                write(14,*)fff,ttt,v1tmp(ifi,itet)
            end do
        end do
        close(14)

	open(14,file='../../../TMP_files/hor/vpvs'//it//lv//'.grd')
	write(14,'(a4)')dsaa
	write(14,*)nfmap,ntmap
	write(14,*)fmap1+fi0,fmap2+fi0
	write(14,*)tmap1+tet0,tmap2+tet0
	write(14,*)-999,999
	do itet=1,ntmap
		write(14,*)(v1tmp(ifi,itet),ifi=1,nfmap)
	end do
	close(14)


	write(499,678)it,lv
	678 format('../../../TMP_files/hor/vpvs',a1,a2,'.grd')
	write(499,679)lv
	679 format('../../../TMP_files/hor/ztr',a2,'.dat')
	izzz=zzz
	write(499,575)izzz
	575 format('Vp/Vs, depth=',i3,' km')



end do

close(433)
close(466)
close(499)


!write(cmd,787)ar,md,iter
!787 format('perl ../_vis_n_hor_result/vis_hor.pl ''list_grd.txt'' ''',a8,''' ''',a8,''' !''',i1,'''')

!i=system(cmd)





stop
end
