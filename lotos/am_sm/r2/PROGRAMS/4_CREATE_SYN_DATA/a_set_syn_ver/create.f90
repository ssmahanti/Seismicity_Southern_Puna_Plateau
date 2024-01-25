! Visualization of synthetic model in VERTICAL sections

character*256 cmd
character*4 dsaa/'DSAA'/
character*8 ar,md,line
character*20 scale_dv,scale_vpvs,scale,scale_vp,scale_vs
character*1 ps
character*2 ver,lv
real fia0(100),teta0(100),fib0(100),tetb0(100)
real hlev(100)
real fmark(200,20),tmark(200,20),smark(200,20)
integer nmark(100)

integer kdot_rgb(3)
common/center/fi0,tet0
common/pi/pi,per
common/keys/key_ft1_xy2

allocatable v_ini(:,:),v_abs_ini(:,:,:)


one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0

i=system('mkdir ../../../TMP_files/vert')


open(1,file='../../../model.dat')
read(1,'(a8)')ar	! synthetic model
read(1,'(a8)')md	! synthetic model
close(1)

write(*,*)' ar=',ar,' md=',md

i=system('mkdir -p ../../../PICS/ps/'//ar//'/'//md)
i=system('mkdir -p ../../../PICS/png/'//ar//'/'//md)
i=system('cp ../../../COMMON/gmt/vis_result_gmt.pl ../../../PROGRAMS/4_CREATE_SYN_DATA/a_set_syn_ver/vis_result_gmt.pl')

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
read(1,*,end=741,err=741)
read(1,*,end=741,err=741)
read(1,*,end=741,err=741)key_ft1_xy2
741 close(1)
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

call read_topo(ar)
call read_vref(ar,md)
call read_anom(ar,md)


ksec_ver=1
kps_ver=1
open(2,file='../../../DATA/'//ar//'/setver.dat')
read(2,*)nver
do ii=1,nver
    read(2,*) fia0(ii),teta0(ii),fib0(ii),tetb0(ii)
end do
read(2,*) 
read(2,*) dxsec
read(2,*) zmin,zmax,dzsec
read(2,*) dsmark
read(2,*) dismax
read(2,*) ismth
read(2,*) 
read(2,*,end=551) ksec_ver,kps_ver
read(2,*,end=551) dfmark,dtmark
close(2)
!dxsec=2
!dzsec=2

551 close(2)

open(433,file='../../../TMP_files/list_ver_p.txt')
open(466,file='../../../TMP_files/list_ver_s.txt')

open(16,file='../../../TMP_files/info_map.txt')
write(16,*)nver
write(16,*)fmap1+fi0,fmap2+fi0
write(16,*)tmap1+tet0,tmap2+tet0


do iver=1,nver
    write(ver,'(i2)')iver

	open(777,file='../../../TMP_files/vert/ztr_'//ver//'.dat')
	write(777,*)'-999 -999 0'
	close(777)

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
    npix_x = int(npix_y * dist/(zmax-zmin))
    sinpov=(yb-ya)/dist
    cospov=(xb-xa)/dist
    nxsec=dist/dxsec+1
    dxsec=dist/(nxsec-1)
    nzsec=(zmax-zmin)/dzsec+1
    dzsec=(zmax-zmin)/(nzsec-1)


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
    if(key_ft1_xy2.eq.1) then
        fmark(iver,imark)=fib
        tmark(iver,imark)=tetb
    else
        fmark(iver,imark)=xb
        tmark(iver,imark)=yb
    end if
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
        topo=h_lim(fff,ttt)
        write(11,*)sss,-topo
    end do
    close(11)


    allocate (v_ini(nxsec,nzsec),v_abs_ini(2,nxsec,nzsec))

    write(*,*)' section:',ver,' dist=',dist,' nxsec=',nxsec,' nzsec=',nzsec
    v_ini=0
    v_abs_ini=0
	
    do ips=1,2
        write(ps,'(i1)')ips

        do ix=1,nxsec
            sss=(ix-1)*dxsec
            !write(*,*)' ix=',ix,' sss=',sss,' dist=',dist
            !sss=40
            !if(mod(ix,10).eq.0)write(*,*)' ix=',ix,' sss=',sss
            xcur=xa+((xb-xa)/dist)*sss
            ycur=ya+((yb-ya)/dist)*sss
            if(key_ft1_xy2.eq.1) then
                call decsf(xcur,ycur,0.,fi0,tet0,fff,ttt,h)
            else
                fff=xcur
                ttt=ycur
            end if

            relief=h_lim(fff,ttt)



            !write(*,*)' xcur=',xcur,' ycur=',ycur
            !write(*,*)' fi=',fi,' tet=',tet,' relief=',relief
            do iz=1,nzsec
                zcur=zmin+iz*dzsec
                v0=vrefmod(zcur,ips)
                dv=anomaly(xcur,ycur,zcur,ips)
                !write(*,*)xcur,ycur,zcur,dv
                if (zcur.lt.-4) then
                !change by ssmahanti
                    v_ini(ix,iz)=-999
                    v_abs_ini(ips,ix,iz)=-999
                else
                    v_ini(ix,iz)=dv
                    v_abs_ini(ips,ix,iz)=v0*(1+dv/100)
                end if
            end do

        end do

       open(14,file='../../../TMP_files/vert/syn_dv'//ver//ps//'.xyz')
       open(15,file='../../../TMP_files/vert/syn_abs'//ver//ps//'.xyz')
       do ix=1,nxsec
            sss=(ix-1)*dxsec
            do iz=1,nzsec
                zcur=zmin+iz*dzsec
                write(14,*)sss,-zcur,v_ini(ix,iz)
                write(15,*)sss,-zcur,v_abs_ini(ips,ix,iz)
           end do
        end do
        close(14)
        close(15)




        open(14,file='../../../TMP_files/vert/syn_dv'//ver//ps//'.grd')
        write(14,'(a4)')dsaa
        write(14,*)nxsec,nzsec
        write(14,*)0,dist
        write(14,*)-zmax,-zmin
        write(14,*)-9999,999
        do iz=nzsec,1,-1
            write(14,*)(v_ini(ix,iz),ix=1,nxsec)
        end do
        close(14)

        open(14,file='../../../TMP_files/vert/syn_abs'//ver//ps//'.grd')
        write(14,'(a4)')dsaa
        write(14,*)nxsec,nzsec
        write(14,*)0,dist
        write(14,*)-zmax,-zmin
        write(14,*)-9999,999
        do iz=nzsec,1,-1
            write(14,*)(v_abs_ini(ips,ix,iz),ix=1,nxsec)
        end do
        close(14)

441	continue

		if(ips.eq.1) then
			write(433,666)ver,ps
			666 format('../../../TMP_files/vert/syn_dv',a2,a1,'.grd')
			write(433,667)ver
			667 format('../../../TMP_files/vert/ztr_',a2,'.dat')
			write(433,534)ver
		534 format('P anomalies.  Section ',a2)
		else
			write(466,668)ver,ps
			668 format('../../../TMP_files/vert/syn_dv',a2,a1,'.grd')
			write(466,669)ver
			669 format('../../../TMP_files/vert/ztr_',a2,'.dat')
			write(466,535)ver
		535 format('S anomalies. Section ',a2)
		end if



    end do      ! ips=1,2

    v_ini=0

    !write(*,*)' only  S:',v_abs_ini(1,135,183),v_abs_ini(2,135,183),v_abs_ini(1,135,183)/v_abs_ini(2,135,183)
    !write(*,*)' P and S:',v_abs_ini(1,151,133),v_abs_ini(2,151,133),v_abs_ini(1,151,133)/v_abs_ini(2,151,133)
    !pause


    do ix=1,nxsec
        sss=(ix-1)*dxsec

        do iz=1,nzsec
            zcur=zmin+iz*dzsec
            !write(*,*)sss,zcur,v_abs_ini(1,ix,iz),v_abs_ini(2,ix,iz),v_abs_ini(1,ix,iz)/v_abs_ini(2,ix,iz)
            v_ini(ix,iz)=v_abs_ini(1,ix,iz)/v_abs_ini(2,ix,iz)
        end do
        !pause
    end do

    open(14,file='../../../TMP_files/vert/syn_vpvs'//ver//'.xyz')
    do ix=1,nxsec
        sss=(ix-1)*dxsec
        do iz=1,nzsec
            zcur=zmin+iz*dzsec
            write(14,*)sss,-zcur,v_ini(ix,iz)
        end do
    end do
    close(14)

    open(14,file='../../../TMP_files/vert/syn_vpvs'//ver//'.grd')
    write(14,'(a4)')dsaa
    write(14,*)nxsec,nzsec
    write(14,*)0,dist
    write(14,*)-zmax,-zmin
    write(14,*)-9999,999
    do iz=nzsec,1,-1
        write(14,*)(v_ini(ix,iz),ix=1,nxsec)
    end do
    close(14)


    deallocate(v_ini,v_abs_ini)

end do      ! iver=1,nver
close(16)

close(433)
close(466)

write(cmd,787)ar,md,iter
787 format('perl ../../../PROGRAMS/4_CREATE_SYN_DATA/a_set_syn_ver/vis_result_gmt.pl ',a8,' ',a8,' ',i1,&
' ','../../../TMP_files/list_hor_p.txt ../../../TMP_files/list_ver_p.txt P')
write(*,'(a200)')cmd
i=system(cmd)


write(cmd,788)ar,md,iter
788 format('perl ../../../PROGRAMS/4_CREATE_SYN_DATA/a_set_syn_ver/vis_result_gmt.pl ''',a8,''' ''',a8,''' ''',i1,&
'''',' ''../../../TMP_files/list_hor_s.txt'' ''../../../TMP_files/list_ver_s.txt'' ''S''')
write(*,'(a200)')cmd
i=system(cmd)

stop
end
