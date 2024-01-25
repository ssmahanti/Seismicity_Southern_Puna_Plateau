function velocity(x,y,z,ips)

!write(*,*)' z=',z,' ips=',ips
v0=vrefmod(z,ips)
!write(*,*)' v0=',v0

dv_apr= 0.01 * vert_anom(x,y,z,ips) * v0


dv = anom_3D_xyz_lin_v(x,y,z,ips)

velocity = v0 + dv + dv_apr


return
end
