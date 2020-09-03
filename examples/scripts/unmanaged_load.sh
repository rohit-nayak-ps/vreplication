source env.sh
mkdir -p $VTDATAROOT/vt_0000000100
DB_USER=msandbox
DB_PASS=msandbox
DB_PORT=19327
vttablet \
 $TOPOLOGY_FLAGS \
 -logtostderr \
 -log_queries_to_file $VTDATAROOT/tmp/vttablet_0000000100_querylog.txt \
 -tablet-path "zone1-0000000100" \
 -init_keyspace load1 \
 -init_shard 0 \
 -init_tablet_type replica \
 -port 15100 \
 -grpc_port 16100 \
 -service_map 'grpc-queryservice,grpc-tabletmanager,grpc-updatestream' \
 -pid_file $VTDATAROOT/vt_0000000100/vttablet.pid \
 -vtctld_addr http://localhost:15000/ \
 -db_host 127.0.0.1 \
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
 -vtctld_addr http://$hostname:$vtctld_web_port/ \
 -init_db_name_override test \
 -init_populate_metadata \
 > $VTDATAROOT/vt_0000000100/vttablet.out 2>&1 &

sleep 10

vtctlclient InitShardMaster -force load1/0 zone1-100

# create the vschema
vtctlclient ApplyVSchema -vschema_file sql/vschema_load_initial.json load1
