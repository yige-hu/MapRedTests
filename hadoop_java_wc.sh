#!/bin/bash

HADOOP_BIN=/opt/hadoop/hadoop/bin
MAP_TASKS=4
REDUCE_TASKS=16
BLOCK_SIZE=67108864

MAPRED_FLAGS="-D mapred.map.tasks=$MAP_TASKS -D mapred.reduce.tasks=$REDUCE_TASKS -D fs.local.block.size=$BLOCK_SIZE"
PIPE_FLAGS="-D hadoop.pipes.java.recordreader=true -D hadoop.pipes.java.recordwriter=true"

JAR_DIR="$HOME/yige/MapRedTests/wc_java/wordcount.jar org.myorg.WordCount"
LOGS="$HOME/yige/Scripts/logs/11-15-2013"

iteration=8

$HADOOP_BIN/stop-all.sh
$HADOOP_BIN/start-all.sh
$HADOOP_BIN/hadoop dfsadmin -safemode leave

sleep 10

for input_type in 'gutenberg' 'wiki'
do
for size in '256M' '512M' '1G' '2G' '4G' '8G'
do
	dfs_in=tmp/input-$input_type-$size
	dfs_out=tmp/output-$input_type-$size
	out=$LOGS/logs-$input_type-$size.log
	rm $out
	touch $out
	
	for i in $(eval echo {1..$iteration})
	do
		echo "iteration #"$i
		$HADOOP_BIN/hadoop dfs -rmr $dfs_out
		echo "Hadoop wc using java, input_size="$size >> $out 2>> $out
		$HADOOP_BIN/hadoop jar $JAR_DIR $MAPRED_FLAGS $dfs_in $dfs_out >> $out 2>> $out
#		echo "Hadoop wc using pipe, input_size="$size >> $out2 2>> $out2
#		$HADOOP_BIN/hadoop pipes $MAPRED_FLAGS $PIPE_FLAGS -input $dfs_in -output $dfs_out2 -program bin/wc_cpp_pipe >> $out2 2>> $out2
	done
done
done
