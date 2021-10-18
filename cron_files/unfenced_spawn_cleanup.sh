#!/bin/bash
folder="$(cd ../ && pwd)"
source $folder/config.ini

# Logging
mkdir -p $PATH_TO_STATS/logs
touch $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
echo "`date '+%Y%m%d %H:%M:%S'` Cleanup of unfenced spawnpoints started" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log

outsidefence=$(./getMonmitmFences.sh)

if [ -z "$SQL_password" ]
  then
  mysql -h$DB_IP -P$DB_PORT -u$SQL_user $MAD_DB -e "SET SESSION tx_isolation = 'READ-UNCOMMITTED'; create temporary table $STATS_DB.tmp1 (INDEX (spawnpoint_id)) AS(select spawnpoint_id, count(spawnpoint_id) as 'times' from $STATS_DB.pokemon_history_temp where date(first_scanned) = curdate() group by spawnpoint_id); create temporary table $STATS_DB.tmp2 (INDEX (spawnpoint)) AS(select spawnpoint from $MAD_DB where $outsidefence insert ignore into $STATS_DB.spawn_unused (spawnpoint,latitude,longitude,spawndef,earliest_unseen,last_scanned,first_detection,last_non_scanned,calc_endminsec,eventid) select spawnpoint,latitude,longitude,spawndef,earliest_unseen,last_scanned,first_detection,last_non_scanned,calc_endminsec,eventid from $MAD_DB.trs_spawn a left join $STATS_DB.tmp1 b on a.spawnpoint = b.spawnpoint_id left join $STATS_DB.tmp2 c on a.spawnpoint = c.spawnpoint where b.times < $SPAWN_UNFENCED_TIMES and a.spawnpoint c.spawnpoint_id; select count(*) from $MAD_DB.trs_spawn where spawnpoint in (select spawnpoint_id from $STATS_DB.tmp1 where times < $SPAWN_UNFENCED_TIMES) and spawnpoint in (select spawnpoint from $STATS_DB.tmp2); insert ignore into $STATS_DB.spawn_unused (spawnpoint,latitude,longitude,spawndef,earliest_unseen,last_scanned,first_detection,last_non_scanned,calc_endminsec,eventid) select spawnpoint,latitude,longitude,spawndef,earliest_unseen,last_scanned,first_detection,last_non_scanned,calc_endminsec,eventid from $MAD_DB.trs_spawn where spawnpoint not in (select spawnpoint_id from $STATS_DB.tmp1) and spawnpoint in (select spawnpoint from $STATS_DB.tmp2); select count(*) from $MAD_DB.trs_spawn where spawnpoint not in (select spawnpoint_id from $STATS_DB.tmp1) and spawnpoint in (select spawnpoint from $STATS_DB.tmp2); drop table $STATS_DB.tmp1; drop table $STATS_DB.tmp2;"
  else
  mysql -h$DB_IP -P$DB_PORT -u$SQL_user -p$SQL_password $MAD_DB -e "SET SESSION tx_isolation = 'READ-UNCOMMITTED'; create temporary table $STATS_DB.tmp1 (INDEX (spawnpoint_id)) AS(select spawnpoint_id, count(spawnpoint_id) as 'times' from $STATS_DB.pokemon_history_temp group by spawnpoint_id); create temporary table $STATS_DB.tmp2 (INDEX (spawnpoint)) AS(select spawnpoint from $MAD_DB.trs_spawn where $outsidefence insert ignore into $STATS_DB.spawn_unused (spawnpoint,latitude,longitude,spawndef,earliest_unseen,last_scanned,first_detection,last_non_scanned,calc_endminsec,eventid) select a.spawnpoint,a.latitude,a.longitude,a.spawndef,a.earliest_unseen,a.last_scanned,a.first_detection,a.last_non_scanned,a.calc_endminsec,a.eventid from $MAD_DB.trs_spawn a left join $STATS_DB.tmp1 b on a.spawnpoint = b.spawnpoint_id left join $STATS_DB.tmp2 c on a.spawnpoint = c.spawnpoint where b.times < $SPAWN_UNFENCED_TIMES and a.spawnpoint = c.spawnpoint; delete from $MAD_DB.trs_spawn where spawnpoint in (select spawnpoint_id from $STATS_DB.tmp1 where times < $SPAWN_UNFENCED_TIMES) and spawnpoint in (select spawnpoint from $STATS_DB.tmp2); insert ignore into $STATS_DB.spawn_unused (spawnpoint,latitude,longitude,spawndef,earliest_unseen,last_scanned,first_detection,last_non_scanned,calc_endminsec,eventid) select spawnpoint,latitude,longitude,spawndef,earliest_unseen,last_scanned,first_detection,last_non_scanned,calc_endminsec,eventid from $MAD_DB.trs_spawn where spawnpoint not in (select spawnpoint_id from $STATS_DB.tmp1) and spawnpoint in (select spawnpoint from $STATS_DB.tmp2); delete from $MAD_DB.trs_spawn where spawnpoint not in (select spawnpoint_id from $STATS_DB.tmp1) and spawnpoint in (select spawnpoint from $STATS_DB.tmp2); drop table $STATS_DB.tmp1; drop table $STATS_DB.tmp2; "
fi

rm $PATH_TO_STATS/monmitmfences.txt

echo "`date '+%Y%m%d %H:%M:%S'` Cleanup of unfenced spawnpoints finished" >> $PATH_TO_STATS/logs/log_$(date '+%Y%m').log
