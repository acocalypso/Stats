#!/bin/bash

folder="$(cd ../ && pwd)"
source $folder/config.ini

query(){
if [ -z "$SQL_password" ]
then
  mysql -h$DB_IP -P$DB_PORT -u$SQL_user $STATS_DB -e "$1;"
else
  mysql -h$DB_IP -P$DB_PORT -u$SQL_user -p$SQL_password $STATS_DB -e "$1;"
fi
}

# Logging
mkdir -p $PATH_TO_STATS/logs
touch $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

# rpl 15 area stats
start=$(date '+%Y%m%d %H:%M:%S')
query "CALL rpl15monarea();"
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl15 mon area processing" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

# rpl 15 spawnpoint stats
start=$(date '+%Y%m%d %H:%M:%S')
query "CALL rpl15spawnarea();"
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl15 spawnpoint area processing" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

# rpl 15 quest stats
start=$(date '+%Y%m%d %H:%M:%S')
if [ -z ${vmad+x} ]
then
  query "CALL rpl15questarea_pd();"
else
  query "CALL rpl15questarea_vm();"
fi
stop=$(date '+%Y%m%d %H:%M:%S')
diff=$(printf '%02dm:%02ds\n' $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))/60)) $(($(($(date -d "$stop" +%s) - $(date -d "$start" +%s)))%60)))
echo "[$start] [$stop] [$diff] Stats rpl15 quest area processing" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
