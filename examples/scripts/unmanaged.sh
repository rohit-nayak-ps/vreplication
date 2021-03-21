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
 -port 25100 \
 -grpc_port 26100 \
 -service_map 'grpc-queryservice,grpc-tabletmanager,grpc-updatestream' \
 -pid_file $VTDATAROOT/vt_0000000100/vttablet.pid \
 -vtctld_addr http://localhost:25000/ \
 -db_host 127.0.0.1 \
 -db_port $DB_PORT \
 -db_app_user $DB_USER \
 -db_app_password $DB_PASS \
 -init_db_name_override test \
 -init_populate_metadata \
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
 -vreplication_heartbeat_update_interval 60 \
 -vtctld_addr http://$hostname:$vtctld_web_port/ \
 > $VTDATAROOT/vt_0000000100/vttablet.out 2>&1 &

sleep 10

vtctlclient InitShardMaster -force load1/0 zone1-100
vtctlclient ApplyVSchema -vschema_file sql/vschema_load_initial.json load1
# create the schema
#vtctlclient ApplySchema -sql-file sql/create_commerce_schema.sql commerce

#mysql -h 127.0.0.1 -P $DB_PORT -u msandbox --password=msandbox commerce < sql/insert_commerce_data.sql

# create the vschema
#vtctlclient ApplyVSchema -vschema_file sql/vschema_commerce_initial.json commerce
