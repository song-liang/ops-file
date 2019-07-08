#!/bin/env bash
##

tar zxvf jdk-8u102-linux-x64.tar.gz -C /usr/local/

touch /etc/profile.d/java.sh
cat > /etc/profile.d/java.sh <<"EOF"
#!/bin/bash
JAVA_HOME=/usr/local/jdk1.8.0_102
JAVA_BIN=$JAVA_HOME/bin
JRE_HOME=$JAVA_HOME/jre
PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/lib:$JAVA_HOME/jre/lib/charsets.jar
export  JAVA_HOME  JAVA_BIN JRE_HOME  PATH  CLASSPATH
EOF

source /etc/profile.d/java.sh
java  -version