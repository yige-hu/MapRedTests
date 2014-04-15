#!/bin/bash

HADOOP_BIN=$HOME/hadoop/hadoop/bin
MAP_TASKS=4
REDUCE_TASKS=16
BLOCK_SIZE=134217728

MAPRED_FLAGS="-D mapred.map.tasks=$MAP_TASKS -D mapred.reduce.tasks=$REDUCE_TASKS -D fs.local.block.size=$BLOCK_SIZE"
PIPE_FLAGS="-D hadoop.pipes.java.recordreader=true -D hadoop.pipes.java.recordwriter=true"

JAR_DIR="$HOME/MapRedTests/wc_java/wordcount.jar org.myorg.WordCount"
LOGS="$HOME/Scripts/logs/hadoop_comp_pipe_java"

iteration=5

$HADOOP_BIN/stop-all.sh
$HADOOP_BIN/start-all.sh
$HADOOP_BIN/hadoop dfsadmin -safemode leave

sleep 10


for size in '16MB' '32MB' '64MB'
do
	dfs_in=tmp/input_$size
	dfs_out1=tmp/output_java_$size
	dfs_out2=tmp/output_pipe_$size
	out1=$LOGS/logs_java_$size.log
	out2=$LOGS/logs_pipe_$size.log
	rm $out1
	touch $out1
	rm $out2
	touch $out2
	
	for i in {1 .. $iteration}
	do
		echo "iteration #"$i
		$HADOOP_BIN/hadoop dfs -rmr $dfs_out1
		$HADOOP_BIN/hadoop dfs -rmr $dfs_out2
		echo "Hadoop wc using java, input_size="$size >> $out1 2>> $out1
		$HADOOP_BIN/hadoop jar $JAR_DIR $MAPRED_FLAGS $dfs_in $dfs_out1 >> $out1 2>> $out1 
		echo "Hadoop wc using pipe, input_size="$size >> $out2 2>> $out2
		$HADOOP_BIN/hadoop pipes $MAPRED_FLAGS $PIPE_FLAGS -input $dfs_in -output $dfs_out2 -program bin/wc_cpp_pipe >> $out2 2>> $out2
	done
done
