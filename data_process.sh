#!bin/bash -f

logdir="$HOME/Scripts/logs/hadoop_comp_pipe_java"

out="$logdir/hadoop_comp_pipe_java.log"
rm $out
touch $out

out2="$logdir/stat_hadoop_comp_pipe_java.log"
rm $out2
touch $out2

head "$logdir/deviceInfo.dat" > $out2
echo >> $out2
echo >> $out2

files=`find . -name "*.log"`
readarray -t sorted < <(printf '%s\0' "${files[@]}" | sort -z| xargs -0n1)

i=0
echo >> $out
for f in "${sorted[@]}"
do
        if [ `basename $f` != `basename $out` ] && [ `basename $f` != `basename $out2` ]; then
		i=$(($i+1))
                echo >> $out
                echo '('$i')' $f >> $out
		cat $f | awk '{
				if($5=="Running"){mapFinish=0; reduceBegin=0; reduceFinish=0; print ""}
				if(($1=="Hadoop")){print $0;}
				if($6=="0%"){print "map_begin:",$2,$5,$6,$7,$8}
				if(mapFinish==0 && $6=="100%"){print "map_end:",$2,$5,$6,$7,$8; mapFinish=1;}
				if(reduceBegin==0 && $8=="0%"){temp=$2" "$5" "$6" "$7" "$8;}
				if(reduceBegin==0 && $8!="0%" && $7=="reduce"){print "reduce_begin:",temp; reduceBegin=1;}
				if(reduceFinish==0 && ($8=="100%" || $6=="complete:")){print "reduce_end:",$2,$5,$6,$7,$8; reduceFinish=1}
			}' >> $out
        fi
done


cat $out | awk -v iteration=5 -F'[ :=]+' 'BEGIN{ num=0 }{
		if($1=="(1)" || $1=="(2)" || $1=="(3)" || $1=="(4)" || $1=="(5)" || $1=="(6)"){print $0}
                if($1=="map_begin"){map_begin=$2*3600+$3*60+$4; stat++}
                if($1=="map_end"){map_end=$2*3600+$3*60+$4; stat++}
                if($1=="reduce_begin"){reduce_begin=$2*3600+$3*60+$4; stat++}
                if($1=="reduce_end"){reduce_end=$2*3600+$3*60+$4; stat++}
                if(stat==4){mapper_time[num]=map_end-map_begin; reducer_time[num]=reduce_end-reduce_begin; tot_time[num]=reduce_end-map_begin;
                        print "Mapper time (s)=",mapper_time[num]; print "Reducer time (s)=",reducer_time[num];
                        print "Total time (s)=",tot_time[num]; print "";
                        stat=0; num++}
                if(num==iteration){mapper_sum=0; reducer_sum=0; tot_sum=0; cpu_sum=0;
                        for(i=0;i<iteration;i++){mapper_sum+=mapper_time[i]; reducer_sum+=reducer_time[i]; tot_sum+=tot_time[i]}
                        print "Average mapper time (s)=",mapper_sum/iteration; print "Average reducer time (s)=",reducer_sum/iteration;
                        print "Average total time (s)=",tot_sum/iteration; print "";
                        num=0}

}' >> $out2
