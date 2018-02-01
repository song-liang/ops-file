date /t >>ts2000.log
time /t >>ts2000.log
netstat -n -p tcp | find ":20021">>ts2000.log
start Explorer