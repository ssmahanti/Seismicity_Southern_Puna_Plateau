subroutine reftrace(alfa,zzt,zstat,ips,izgib, time,dist,hmax)


! zstat : starting level
! alfa : dipping angle at the starting level
! zzt : finishing level. It is always above that zstart
! izgib : marker. When 0, the ray goes


real zzz(300),rrr(300),vvv(300)

common/refmod/nrefmod,zref(600),vref(600,2)
common/pi/pi,per

!write(*,*)alfa,zstat,zzt,izgib



rz=6378.

dist=-999.
time=-999.

if (alfa.gt.90..and.zzt.le.zstat) then
	hmax=zzt
	return
end if

!write(*,*)' nrefmod=',nrefmod
rstat=rz-zstat
vstat=vrefmod(zstat,ips)
vzt=vrefmod(zzt,ips)
!write(*,*)' zzt=',zzt,' vzt=',vzt,' ips=',ips
rzt=rz-zzt

zup=zstat
vup=vstat
zlow=zzt
vlow=vzt

if(zzt.lt.zstat) then
	zup=zzt
	vup=vzt
	zlow=zstat
	vlow=vstat
end if

rup=rz-zup
rlow=rz-zlow


nref=nrefmod+1
do i=1,nref-1
	rrr(i)=rz-zref(i)
	vvv(i)=vref(i,ips)
end do
rrr(nref)=0
vvv(nref)=15.

!do i=1,nref
!	write(*,*)rrr(i),vvv(i)
!end do

sina=sin(alfa*per)

p=rzt*sina/vzt

!write(*,*)' p=',p,' vzt=',vzt

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Tracing from rup to rlow
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!write(*,*)' rup=',rup,' rlow=',rlow

ep1=0.
time1=0.

if(abs(alfa-90).lt.1.e-9) then
	rmax=rlow
	hmax=rz-rmax
	rlow=rup
	vlow=vup
	goto 883
end if


if(abs(rup-rlow).lt.1.e-9) goto 883

do il=1,nref-1
	v1=vvv(il)
	v2=vvv(il+1)
	r1=rrr(il)
	r2=rrr(il+1)
!write(*,*)' ini: r1=',r1,' r2=',r2
	if(r2.gt.rup) cycle
	if(r1.le.rlow) exit
	if((r1-rup)*(r2-rup).lt.0.)then
		v1=vup
		r1=rup
	end if
	if((r1-rlow)*(r2-rlow).le.0.)then
		v2=vlow
		r2=rlow
	end if
!write(*,*)' aft: r1=',r1,' r2=',r2
!write(*,*)' aft: v1=',v1,' v2=',v2
	p2=r2/v2
	if(r2.eq.r1.and.p2.gt.p) cycle
	if(r2.eq.r1.and.p2.le.p) then
		hmax=rz-r2
		exit
	end if
	call ray_lay(r1,r2,v1,v2,p,dt,dep)
	!write(*,*)' z1=',rz-r1,' z2=',rz-r2,dt,dep*rz
	!if(il.eq.16)write(*,*)' v1=',v1,' v2=',v2,' p=',p
	!write(*,*)il,' dt=',dt,' dep=',dep,' dz=',r2-r1
	!if(il.eq.32) pause
	time1=time1+dt
	ep1=ep1+dep
	if(p2.le.p) then
		aaa=(v1-v2)/(r1-r2)
		bbb=(v2*r1-v1*r2)/(r1-r2)
		hmax=rz-p*bbb/(1.-p*aaa)
		!write(*,*)' h1=',rz-r1,' h2=',rz-r2
		!write(*,*)' v1=',v1,' v2=',v2
		!write(*,*)' p=',p,' p2=',p2
		!write(*,*)' hmax=',hmax
		return
	end if
	!write(*,*)' il=',il,' h1=',rz-r1,' h2=',rz-r2
	!if(il.eq.16)write(*,*)il,v1,v2,ep1*rz,dep*rz
end do

!write(*,*)' ep1=',ep1,' time1=',time1

883 continue

ep2=0.
time2=0.
hmax=zlow

if(alfa.gt.90+1.e-9)goto 334
if (izgib.eq.0.and.zstat.gt.zzt) goto 334


!write(*,*)' rup=',rup,' rlw=',rlow
!write(*,*)' vup=',vup,' vlw=',vlow


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Compute the maximal depth of the ray
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
do ilay=1,nref-1
	v1=vvv(ilay)
	v2=vvv(ilay+1)
	r1=rrr(ilay)
	r2=rrr(ilay+1)
	p2=r2/v2
	if(p2.gt.p) cycle
	if(r2.eq.r1.and.p2.lt.p) exit
	aaa=(v1-v2)/(r1-r2)
	bbb=(v2*r1-v1*r2)/(r1-r2)
	rmax=p*bbb/(1.-p*aaa)
	if((r1-rmax)*(r2-rmax).le.0.)goto 3
end do
ilay=ilay-1
3 continue
hmax=rz-rmax
vmax=vrefmod(hmax,ips)



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Tracing from rlow to rmax
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
884	continue

do il=1,nref-1
	v1=vvv(il)
	v2=vvv(il+1)
	r1=rrr(il)
	r2=rrr(il+1)
!write(*,*)' ini: r1=',r1,' r2=',r2
	if(r2.ge.rlow) cycle
	if(r1.le.rmax) exit
	if((r1-rlow)*(r2-rlow).lt.0.)then
		v1=vlow
		r1=rlow
	end if
	if(r2.eq.r1) cycle
!write(*,*)' aft: r1=',r1,' r2=',r2
	call ray_lay(r1,r2,v1,v2,p,dt,dep)
!	write(*,*)' v1=',v1,' v2=',v2,' p=',p
!	write(*,*)' r1=',r1,' r2=',r2,' dt=',dt,' dep=',dep
	time2=time2+dt
	ep2=ep2+dep
!write(*,*)' dep=',dep,' dt=',dt
!write(*,*)
end do

!write(*,*)' ep2=',ep2,' time2=',time2

334 continue

time=time2*2.+time1
ep=ep2*2.+ep1
if(abs(alfa-90).lt.1.e-9)ep=ep2
if(abs(alfa-90).lt.1.e-9)time=time2
dist=ep*rz

!write(*,*)' time1=',time1,' ep1=',ep1
!write(*,*)' time2=',time2,' ep2=',ep2
!write(*,*)' alfa=',alfa,' dist=',dist,' time=',time

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!write(*,*)' time=',time,' dist=',dist
return
end


