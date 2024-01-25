# Download SACPZ response information for X6 stations from IRISDMC.

filename="x6_stations.txt"
 
while read line
do
    # $line variable contains current line read from the file
    echo "$line"
    curl -o SACPZ.X6.NS18.BHN "http://service.iris.edu/irisws/sacpz/1/query?net=X6&sta=NS18&loc=*&cha=BHN&starttime=2008-01-01T00:00:00&endtime=2009-09-30T00:00:00"

done < $filename
