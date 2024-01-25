character*256 cmd
character*4 dsaa/'DSAA'/
character*8 ar,md,line
character*1 ps
character*2 lv
real hlev(100)
character*20 scale_dv,scale_vpvs
integer line1_rgb(3),line2_rgb(3),kdot_rgb(3)

allocatable v_ini(:,:),v_abs(:,:,:)
common/center/fi0,tet0
common/pi/pi,per
common/keys/key_ft1_xy2

one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0

open(1,file='../../../model.dat')
read(1,'(a8)')ar	! synthetic model
read(1,'(a8)')md	! synthetic model
close(1)

i=system('mkdir ../../../../TMP_files/hor')
i=system('mkdir -p ../../../PICS/ps/'//ar//'/'//md)
i=system('mkdir -p ../../../PICS/png/'//ar//'/'//md)


write(*,*)' Synthetic model in horizontal sections'
write(*,*)' ar=',ar,' md=',md


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

!write(*,*)' key_ft1_xy2=',key_ft1_xy2
!pause

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

open(2,file='../../../DATA/'//ar//'/sethor.dat')
read(2,*) nlev  
read(2,*) (hlev(i),i=1,nlev)  
read(2,*) fmap1,fmap2,dfmap,tmap1,tmap2,dtmap  
close(2)

dfmap=dfmap/2.
dtmap=dtmap/2.

nfmap=int_best((fmap2-fmap1)/dfmap+1.)
ntmap=int_best((tmap2-tmap1)/dtmap+1.)
write(*,*)' nfmap=',nfmap,' ntmap=',ntmap


allocate(v_ini(nfmap,ntmap),v_abs(nfmap,ntmap,2))

open(433,file='../../../TMP_files/list_hor_p.txt')
open(466,file='../../../TMP_files/list_hor_s.txt')


DO ilev=1,nlev
    zzz=hlev(ilev)
    write(lv,'(i2)')ilev
    write(*,*)' ilev=',ilev,' zzz=',zzz
    v_abs=0
    do ips=1,2
        write(ps,'(i1)')ips
        vref=vrefmod(zzz,ips)

	open(777,file='../../../TMP_files/hor/ztr'//lv//'.dat')
	write(777,*)'-999 -999 0'
	close(777)

	!write(*,*)' ilev=',ilev,' zzz=',zzz
	open(11,file='../../../TMP_files/hor/ztr'//lv//'.dat')
	write(11,*)fi0,tet0,zzz
	close(11)


        v_ini=0

        do itet=1,ntmap
            ttt=(itet-1)*dtmap+tmap1+tet0
            !write(*,*)' itet=',itet,' ttt=',ttt
            !ttt=-7.35
            do ifi=1,nfmap
                fff=(ifi-1)*dfmap+fmap1+fi0
                relief=h_lim(fff,ttt)

                !fff=-71.7450025271; ttt=-39.6020187759

                if (zcur.lt.relief) then
                    v_ini(ifi,itet)=-999
                    cycle
                end if
                if(key_ft1_xy2.eq.1) then
                    call SFDEC(fff,ttt,0.,xxx,yyy,Z,fi0,tet0)
                else
                    xxx=fff
                    yyy=ttt
                end if
                dv=anomaly(xxx,yyy,zzz,ips)
                !write(*,*)' fi=',fff,' tet=',ttt,' dv=',dv
                !write(*,*)' x=',xxx,' y=',yyy,' z=',zzz,' dv=',dv
                !pause

                if (zzz.lt.h_lim(fff,ttt)) dv=0
                v_ini(ifi,itet)=dv
                v_abs(ifi,itet,ips)=vref*(1+dv/100)


                !pause
                !pause
            end do
        end do
  
       open(14,file='../../../TMP_files/hor/syn'//ps//'_'//lv//'.xyz')
       do itet=1,ntmap
            ttt=(itet-1)*dtmap+tmap1+tet0
            do ifi=1,nfmap
                fff=(ifi-1)*dfmap+fmap1+fi0
                write(14,*)fff,ttt,v_ini(ifi,itet)
            end do
        end do
        close(14)


        open(14,file='../../../TMP_files/hor/syn'//ps//'_'//lv//'.grd')
        write(14,'(a4)')dsaa
        write(14,*)nfmap,ntmap
        write(14,*)fmap1+fi0,fmap2+fi0
        write(14,*)tmap1+tet0,tmap2+tet0
        write(14,*)-999,999
        do itet=1,ntmap
            write(14,*)(v_ini(ifi,itet),ifi=1,nfmap)
        end do
        close(14)



	izzz=zzz
	if(ips.eq.1) then
		write(433,666)ps,lv
		666 format('../../../TMP_files/hor/syn',a1,'_',a2,'.grd')
		write(433,667)lv
		667 format('../../../TMP_files/hor/ztr',a2,'.dat')
		write(433,534)izzz
	534 format('P anomalies, depth=',i3,' km')
	else
		write(466,668)ps,lv
		668 format('../../../TMP_files/hor/syn',a1,'_',a2,'.grd')
		write(466,669)lv
		669 format('../../../TMP_files/hor/ztr',a2,'.dat')
		write(466,535)izzz
	535 format('S anomalies, depth=',i3,' km')
	end if


	 

    end do


! IMAGE THE VP/VS RATIO:


    open(14,file='../../../TMP_files/hor/syn_vpvs_'//lv//'.xyz')
    do itet=1,ntmap
        ttt=(itet-1)*dtmap+tmap1+tet0
        do ifi=1,nfmap
            fff=(ifi-1)*dfmap+fmap1+fi0
            write(14,*)fff,ttt,v_abs(ifi,itet,1)/v_abs(ifi,itet,2)
        end do
    end do
    close(14)



    open(14,file='../../../TMP_files/hor/syn_vpvs_'//lv//'.grd')
    write(14,'(a4)')dsaa
    write(14,*)nfmap,ntmap
    write(14,*)fmap1+fi0,fmap2+fi0
    write(14,*)tmap1+tet0,tmap2+tet0
    write(14,*)-999,999
    do itet=1,ntmap
        write(14,*)(v_abs(ifi,itet,1)/v_abs(ifi,itet,2),ifi=1,nfmap)
    end do
    close(14)

 
end do
close(433)
close(466)


stop
end
