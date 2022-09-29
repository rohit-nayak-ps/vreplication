mkdir -p $VTDATAROOT/vt_0000000200
DB_USER=vitess
DB_PASS=V3l0c!Raptor
DB_PORT=3306
DB_HOST=aws1

vttablet \
 $TOPOLOGY_FLAGS \
 -logtostderr \
 -log_queries_to_file $VTDATAROOT/tmp/vttablet_0000000200_querylog.txt \
 -tablet-path "zone1-0000000200" \
 -init_keyspace load2 \
 -init_shard 0 \
 -init_tablet_type replica \
 -port 25200 \
 -grpc_port 26200 \
 -service_map 'grpc-queryservice,grpc-tabletmanager,grpc-updatestream' \
 -pid_file $VTDATAROOT/vt_0000000200/vttablet.pid \
 -vtctld_addr http://localhost:25000/ \
 -db_host $DB_HOST \
 -db_port $DB_PORT \
 -db_app_user $DB_USER \
 -db_app_password $DB_PASS \
 -db_allprivs_user $DB_USER \
-db_allprivs_password $DB_PASS \
-db_appdebug_user $DB_USER \
-db_appdebug_password $DB_PASS \
-db_dba_user $DB_USER \
-db_dba_password $DB_PASS \
-db_filtered_user $DB_USER \
-db_filtered_password $DB_PASS \
-db_repl_user $DB_USER \
-db_repl_password $DB_PASS \
-track_schema_versions=true \
-vtctld_addr http://$hostname:$vtctld_web_port/ \
-init_db_name_override load2 \
-init_populate_metadata \
-relay_log_max_size 10000000 \
-relay_log_max_items 50000 \
-tablet_hostname ROHIT-UBUNTU \
> $VTDATAROOT/vt_0000000200/vttablet.out 2>&1 &

sleep 10

$LVTCTL  InitShardPrimary -force load2/0 zone1-200

mysql -h aws1 -u vitess --password=V3l0c\!Raptor test -e "drop database if exists load2"
mysql -h aws1 -u vitess --password=V3l0c\!Raptor test -e "drop database if exists _vt"
mysql -h aws1 -u vitess --password=V3l0c\!Raptor test -e "create database load2"

# create the vschema
#vtctlclient ApplyVSchema -vschema_file sql/vschema_load_initial.json load2
