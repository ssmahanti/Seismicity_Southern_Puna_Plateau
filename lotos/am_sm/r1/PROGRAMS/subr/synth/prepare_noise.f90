subroutine prepare_noise(ar,md)

real hist(2,100)
character*8 ar,md,ar_ini,md_ini
integer*2 k12,k22,k32,k42

common/histo/istep,xconv(2000),xdir1,xdir2,dxdir
common/noise_1/a_rand(2),n_perc_out,a_out,a_stat
common/noise_2/kod_noise,ar_ini,md_ini,it_ini,red_ps(2)


open(1,file='../../../DATA/'//ar//'/'//md//'/noise.dat',status='old',err=1313)
goto 1212
1313 kod_noise=0
return

1212 read(1,*)kod_noise		! code of the noise
read(1,*)

if(kod_noise.eq.2) then
	read(1,*)ar_ini
	read(1,*)md_ini
	read(1,*)it_ini
	read(1,*)red_ps(1),red_ps(2)
	close(1)
	return
else if(kod_noise.eq.1) then

        !call gettim(k12,k22,k32,k42)
        !k4=k42
	k4=1

	CALL SRAND(k4)
	read(1,*)a_rand_p,a_rand_s		! Average level of noise
	read(1,*)n_perc_out
	read(1,*)a_out
	read(1,*)a_stat
	read(1,*)
	read(1,*)
	read(1,*)	! Read histogram of noise distribution:
	read(1,*)nconvert
	read(1,*)ds
	do i=1,100
		read(1,*,end=1)hist(1,i),hist(2,i)
	end do
	pause ' Warning: nhist > 100'
	1 nhist=i-1
	close(1)

	write(*,*)' Noise: amp=',a_rand_p,a_rand_s,' outliers:',n_perc_out,a_out

	amax=0
	do i=1,nhist
		if(hist(2,i).gt.amax) amax=hist(2,i)
	end do


	xdir1=0
	xdir2=1
	dxdir=(xdir2-xdir1)/nconvert

	! Integration

	sum=0
	do i=1,nhist-1
		x1=hist(1,i)
		y1=hist(2,i)
		x2=hist(1,i+1)
		y2=hist(2,i+1)
		sum=sum+(x2-x1)*(y1+y2)/2
	end do

	write(*,*)' sum=',sum

	porog=sum/nconvert

	istep=1


	xconv(istep)=hist(1,1)

	dsum=0
	do i=1,nhist-1
		x1=hist(1,i)
		x2=hist(1,i+1)
		y1=hist(2,i)
		y2=hist(2,i+1)
		nstep=(x2-x1)/ds
		dss=(x2-x1)/nstep
		dydx=(y2-y1)/(x2-x1)
		x3=x1
		y3=y1
		do ii=1,nstep
			x4=x3+dss
			y4=y1+dydx*(x4-x1)
			dsum=dsum+(x4-x3)*(y4+y3)/2
			x3=x4
			y3=y4

			if(dsum.lt.porog) cycle

			!write(*,*)' x4=',x4,' dsum=',dsum,' porog=',porog
			istep=istep+1
			xconv(istep)=x4
			dsum=0
		end do
	end do
	istep=istep+1
	xconv(istep)=hist(1,nhist)


	nfreq_out=10000000
	if(n_perc_out.ne.0)nfreq_out=100/n_perc_out

	a_rand(1)=a_rand_p/1.578966
	a_rand(2)=a_rand_s/1.578966


	disp=0
	do i=1,100000
		a=our_noise(1,0.0,1)
		disp=disp+abs(a)
	end do
	disp=disp/100000
	write(*,*)' disp P=',disp


	disp=0
	do i=1,100000
		a=our_noise(1,0.0,2)
		disp=disp+abs(a)
	end do
	disp=disp/100000
	write(*,*)' disp S=',disp
else
	write(*,*)' kod_noise=',kod_noise,' is not defined'
	pause

end if

!write(*,*)' disp=',disp,' a_rand=',a_rand

!disp=0
!do i=1,100000
!	a=our_noise(1,0.0)
!	disp=disp+abs(a)
!end do
!disp=disp/100000
!write(*,*)' disp=',disp
!pause

return
end
