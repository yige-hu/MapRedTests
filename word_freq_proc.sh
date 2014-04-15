#!bin/bash -f

out='stat_result.dat'
rm $out
touch $out

sum=`cut -f2 result | paste -sd+ | bc`
echo "sum="$sum >> $out

cut -f2 result | sort -nr -k1 | awk -v SUM=$sum 'BEGIN{
p2 = 0; p4 = 0; p6 = 0; p8 = 0;
}{
count ++;
s += $1;
if (p2 == 0 && s >= SUM*0.2) { pos20=count}
if (p4 == 0 && s >= SUM*0.4) { pos40=count}
if (p6 == 0 && s >= SUM*0.6) { pos60=count}
if (p8 == 0 && s >= SUM*0.8) { pos80=count}
}END{
print "Top 5 words percentage: "w5*100/s"%";
print "Top 10 words percentage: "w10*100/s"%";
print "Top 20 words percentage: "w20*100/s"%";
print "Top 30 words percentage: "w30*100/s"%";
print "Top 40 words percentage: "w40*100/s"%";
print "20% of the whole text comes from" 100*pos20/count"% most frequent words"
print "40% of the whole text comes from" 100*pos40/count"% most frequent words"
print "60% of the whole text comes from" 100*pos60/count"% most frequent words"
print "80% of the whole text comes from" 100*pos80/count"% most frequent words"
}' >> $out

