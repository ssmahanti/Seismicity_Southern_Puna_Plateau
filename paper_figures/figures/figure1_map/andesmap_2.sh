#This script plots figure 1b:

#Config parameters
gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset MAP_FRAME_WIDTH 2p
gmt gmtset FONT_ANNOT_PRIMARY 10p,Helvetica,black
gmt gmtset FORMAT_GEO_MAP=D
gmt gmtset FONT_LABEL		= 10p

#Projection and boundaries
proj="-JM5i"
range="-R-80/-50/-40/-10"
B="-Ba5f5:::,:/a5f5:::,:WeSn"

#filepaths
stationpath="/Users/sankha/Desktop/research/Spuna_plateau/station"
plotdatapath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata"
grdpath="/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/grdfiles"

output="andesmap_2.ps"

#cptfiles
gmt makecpt -T-15000/6000/20   -Cgeo> topo3.cpt

#Plot map and topography
gmt psbasemap $proj $range $B  -K >  $output
gmt grdcut $grdpath/ETOPO1.grd -GSAM.grd $range
gmt grdgradient SAM.grd -Nt1 -A45 -GSAM_temp.grd
gmt grdimage $grdpath/ETOPO1.grd -ISAM_temp.grd -Ctopo3.cpt $range $proj -O -K -t20 >>$output

#Trench
gap=0.6
size=0.06
gmt psxy $plotdatapath/trench.txt $proj $range  -W1p,black  -Sf${gap}i/${size}i+l+t -G0 -O -K >> $output

#Plot the tectonic units
gmt psxy $plotdatapath/tectonic_units/apvc.txt $proj $range  -W0.31p,black -G255/236/139   -O -K -t30 >> $output #Plateau
gmt psxy $plotdatapath/tectonic_units/subandean.txt $proj $range  -W0.3p,black -K  -O -Gcoral1 -t50 >> $output #Sub-Andean
gmt psxy $plotdatapath/tectonic_units/WC.txt $proj $range  -W0.3p,black  -K  -O -Gpink1 -t50 >> $output #Western Cordillera
gmt psxy $plotdatapath/tectonic_units/prc.txt $proj $range  -W0.31p,black  -K  -O -Gsteelblue1  -t50 >> $output #Pre-cordillera
gmt psxy $plotdatapath/tectonic_units/EC.txt $proj $range  -W0.31p,black  -O -Glightslateblue -t50  -K>> $output #Eastern Cordillera

gmt psxy $proj $range -W1.5,black -O  -K<< EOF >> $output
-69.5 -25
-66.5 -25
-66.5 -28.5
-69.5 -28.5
-69.5 -25
EOF

gmt gmtset FONT_ANNOT_PRIMARY 8p,Helvetica,black
gmt gmtset FONT_LABEL		= 8p
gmt gmtset MAP_LABEL_OFFSET		= 2p
gmt psbasemap  $proj $range  -LjBL+c27S+w400k+l+ab+f+o0.2c/0.8c -P  -O >> $output

gmt psconvert -Tf -E300 $output -A1
gmt psconvert -Tg -E300 $output -A1

rm *.grd *.cpt *.ps *.txt