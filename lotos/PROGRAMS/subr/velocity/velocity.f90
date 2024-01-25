function velocity(x,y,z,ips)

v0=vrefmod(z,ips)



dv_prev=dv_mod_2d(x,y,z,ips)

velocity = v0 + dv_prev

return
end