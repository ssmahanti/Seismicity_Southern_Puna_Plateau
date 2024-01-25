character*8 ar
real fst(1000),tst(1000),zst(1000)
integer kodst2(1000)

one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0


open(1,file='../../../model.dat',status='old',err=221)
read(1,'(a8)',err=221)ar		! code of the area
close(1)
goto 2
221 write(*,*)' file model.dat does not exist'
stop
2 continue

write(*,*)' area=',ar


! Read the coordinates of the stations
open(1,file='../../../DATA/'//ar//'/inidata/stat_ft.dat',status='old',err=222)
nst=0
33	read(1,*,end=44)fi,tet,zstat
	nst=nst+1
	fst(nst)=fi
	tst(nst)=tet
	zst(nst)=zstat
	goto 33
44	close(1)
close(1)
write(*,*)' Total number of stations in the list:',nst
goto 3

222 write(*,*)' file stat_ft.dat does not exist'
stop

3 continue


open(1,file='../../../DATA/'//ar//'/inidata/rays.dat',status='old',err=223)
goto 4

223 write(*,*)' file rays.dat does not exist'
stop

4 continue

open(11,file='../../../DATA/'//ar//'/inidata/sources_ini.dat')

nline=0
nray=0
nsrc=0
nst2=0
fztav=0
tztav=0
fmin=9999999
fmax=-9999999
tmin=9999999
tmax=-9999999
! Read the sources:
992	continue
    read(1,*,end=991)fini,tini,zold,nkrat
    write(11,*)fini,tini,zold
    nline=nline+1

    nsrc=nsrc+1
    fztav=fztav+fini
    tztav=tztav+tini

    if(fini.lt.fmin) fmin=fini
    if(fini.gt.fmax) fmax=fini
    if(tini.lt.tmin) tmin=tini
    if(tini.gt.tmax) tmax=tini

    do i=1,nkrat
        nline=nline+1
        read(1,*,end=224,err=224)ips,ist,tobs
        if(ips.ne.1.and.ips.ne.2) goto 225
        if(ist.le.0.or.ist.gt.nst) goto 225

        nray=nray+1
        if(nst2.ne.0) then
            do ist2=1,nst2
                if(ist.eq.kodst2(ist2)) goto 5
            end do
        end if
        nst2=nst2+1
        kodst2(nst2)=ist

5       continue
    end do
    goto 992

991 close(1)
close(11)
write(*,*)' File rays.dat contains lines: ',nline
write(*,*)' Number of events:',nsrc
write(*,*)' Number of picks:',nray
write(*,*)' Number of stations involved:',nst2

faver=0
taver=0
open(11,file='../../../DATA/'//ar//'/inidata/stat_actual.dat')

do ist2=1,nst2
    ist=kodst2(ist2)
    fstat2=fst(ist)
    tstat=tst(ist)
    zstat=zst(ist)
    faver=faver+fstat2
    taver=taver+tstat
    write(11,*)fstat2,tstat,zstat
    if(fstat2.lt.fmin) fmin=fstat2
    if(fstat2.gt.fmax) fmax=fstat2
    if(tstat.lt.tmin) tmin=tstat
    if(tstat.gt.tmax) tmax=tstat
end do
close(11)
faver=faver/nst2
taver=taver/nst2

write(*,*)' center of the station network: fi=',faver,' tet=',taver
write(*,*)' fmin=',fmin,' fmax=',fmax
write(*,*)' tmin=',tmin,' tmax=',tmax

cost=cos(taver*per)
npix_y=700
npix_x=((fmax-fmin)/(tmax-tmin)) * cost * npix_y


fztav=fztav/nsrc
tztav=tztav/nsrc

write(*,*)' average source point: fi=',fztav,' tet=',tztav

goto 229


stop

224 write(*,*)' Problem in file rays.dat around line:',nline
stop
225 write(*,*)' Problem in file rays.dat around line:',nline
write(*,*)' ips=',ips,' ist=',ist
stop


229 continue

stop
end
