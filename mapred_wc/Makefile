CC = g++
HADOOP_INSTALL = /home/hdyige/hadoop/hadoop
PLATFORM = Linux-amd64-64
#CPPFLAGS = -m64 -I$(HADOOP_INSTALL)/c++/$(PLATFORM)/include
CPPFLAGS = -m64 -I$(HADOOP_INSTALL)/src/c++/install/include

mapred_wc: mapred_wc.cpp
	$(CC) $(CPPFLAGS) $< -Wall -L$(HADOOP_INSTALL)/src/c++/install/lib -lhadooppipes \
	-lhadooputils -lpthread -g -O2 -o $@ -lssl -lcrypto
#	$(CC) $(CPPFLAGS) $< -Wall -L$(HADOOP_INSTALL)/c++/$(PLATFORM)/lib -lhadooppipes \
#	-lhadooputils -lpthread -g -O2 -o $@ -lssl -lcrypto
