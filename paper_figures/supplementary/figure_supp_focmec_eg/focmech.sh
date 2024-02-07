#The pspolar plot needs gmt 6 which is activated through a conda enviroment gmtenv in my case: 
#Plots the focal mechanism along with arrivals

echo "-67 -26 5 136 84 18 7.0 0 0" | gmt psmeca -J -R  -Sa3.6   -Ggray23 -N   -K >focmec.ps #plot beachball
gmt pspolar puna_20081204143_i.inp -R-77/-57/-36/-16 -JM5c -Sh5p -D-67/-26 -M5 -Ecyan -Gred -O -K>> focmec.ps #Impulsive arrivals
gmt pspolar puna_20081204143_e.inp -R-77/-57/-36/-16 -JM5c -Sc3p -D-67/-26 -M5 -Ecyan -Gred -O >> focmec.ps #Emergent arrivals

gmt psconvert -Tf -A1 -E300 focmec.ps

rm *.ps