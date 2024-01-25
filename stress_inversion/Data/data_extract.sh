#Script to extract the focal mechanism of the events in different clusters:
#Salar=1; SP=2; Southern Part=3; Northern part=4; All:>0

echo "%Puna north">puna_mech_all_v5.dat #all events
echo "%Strike Dip Rake">>puna_mech_all_v5.dat

focmecpath="/Users/sankha/Desktop/research/southern_puna/focmec/output"

#Selecting events where error in mechanism is lesser than 30 degrees:
cat $focmecpath/focmec_output.txt | awk '{ if ( $16>0 && $10<=30 && $11<=30 && $12<=30) print $7,$8,$9}'>>puna_mech_all_v5.dat