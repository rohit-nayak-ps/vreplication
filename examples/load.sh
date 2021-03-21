
setup(){
  echo ">>>>> Cleaning up previous runs, if any"
  ./cleanup.sh


  echo ">>>>>> Starting etcd"
  scripts/etcd-up.sh
  echo ">>>>>> Starting vtctld"
  scripts/vtctld-up.sh
  echo ">>>>>> Starting vtgate"
  scripts/vtgate-up.sh
  sleep 2
  mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox test -e "truncate table _vt.resharding_journal"
  mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox test -e "truncate table _vt.vreplication"
  mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox test -e "truncate table _vt.resharding_journal"
  mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox test -e "truncate table _vt.vreplication"
  mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox test -e "truncate table _vt.copy_state"
  mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox test -e "drop database load2;create database load2;"
}

unmanaged(){
  echo ">>>>>> Step 1: Starting unmanaged tablet (load1 keyspace)"
  scripts/unmanaged.sh
  sleep 5
  echo ">>>>>> Step 1: Starting unmanaged tablet (load2 keyspace)"
  scripts/unmanaged_load.sh
  sleep 5
}

mat() {
  spec_template="{\"workflow\": \"mat\",\"sourceKeyspace\": \"product\",\"targetKeyspace\": \"c1m\",\"tableSettings\": [{\"targetTable\": \"c1m_XXX\",\"sourceExpression\": \"select * from c1m\",\"create_ddl\": \"create table c1m_XXX(c1 bigint(20),val2 default null primary key(c1))\"}]}"

  for t in {1..3}
  do
    spec=${spec_template/XXX/$t}
    echo "spec is $spec"
    $LVTCTL Materialize spec
    if [ $? -eq 1 ]
    then
       echo "Error in Materialize, exiting"
       exit
    fi
  done
}

movetables(){
  echo ">>>>>> Step 2: Starting load2 tablets"
  for shard in "0"; do
    for i in 200 201 202;  do
      CELL=zone1 TABLET_UID=$i ./scripts/mysqlctl-up.sh
      CELL=zone1 KEYSPACE=load2 TABLET_UID=$i SHARD=$shard ./scripts/vttablet-up.sh
    done
  done

  sleep 10

  $LVTCTL InitShardMaster -force load2/0 zone1-200

  sleep 2
  echo ">>>>>> Step 3. Calling MoveTables"
  TABLE=c2
  WORKFLOW=mt
  SOURCE_KS=load1
  TARGET_KS=load2
  KSWF=$TARGET_KS.$WORKFLOW
  $LVTCTL MoveTables -all -tablet_types=MASTER -workflow=$WORKFLOW $SOURCE_KS $TARGET_KS
  if [ $? -eq 1 ]
  then
     echo "Error in MoveTables, exiting"
     exit
  fi
exit
  # TABLE2=c3
  # WORKFLOW2=mt2
  # $LVTCTL MoveTables -tablet_types=MASTER -workflow=$WORKFLOW2 $SOURCE_KS $TARGET_KS $TABLE2
  # if [ $? -eq 1 ]
  # then
  #    echo "Error in MoveTables, exiting"
  #    exit
  # fi
  exit
  echo ">>>>> Step 4. Waiting for Vreplication to copy the data ..."
  sleep 5
  echo ">>>>> Step 5. Run VDiff "
  $LVTCTL VDiff $KSWF

  echo ">>>>>> Step 6. Calling SwitchReads"
  $LVTCTL SwitchReads -tablet_type=rdonly $KSWF
  if [ $? -eq 1 ]
  then
     echo "Error in SwitchReads, exiting"
     exit
  fi
  $LVTCTL SwitchReads -tablet_type=replica $KSWF
  sleep 5
  echo ">>>>>> Step 7. Calling SwitchWrites"
  $LVTCTL SwitchWrites $KSWF
  sleep 2
  #$LVTCTL DropSources $KSWF
  #TODO: if you remove this you get the "buildResharder: readRefStreams: blsIsReference: table c2 not found in vschema" ERROR
  /usr/bin/mysql -S /home/rohit/vtdataroot/vt_0000000200/mysql.sock -u vt_dba -e "delete from _vt.vreplication"
}

reshard() {
  # Reshard
  WORKFLOW=rs
  TARGET_KS=load2
  KSWF="$TARGET_KS.$WORKFLOW"

  echo ">>>>>>>> applying schema/vschema"
  $LVTCTL ApplySchema -sql-file sql/c2_seq.sql $TARGET_KS
  $LVTCTL ApplyVSchema -vschema_file sql/load2_sharded_vschema.json $TARGET_KS
  $LVTCTL RebuildVSchemaGraph -cells=zone1

  echo ">>>>>> Step 8: Starting $TARGET_KS tablets"
  shards=('-80' '80-')
  for ((idx=0; idx<${#shards[@]}; ++idx)); do
    shard=${shards[idx]}
    echo "idx $idx, shard is $shard"
    for i in 1 2 3;  do
      TID=`expr 299 + $idx \* 100 + $i`
      echo "Creating tablet $TID"
      CELL=zone1 TABLET_UID=$TID ./scripts/mysqlctl-up.sh
      CELL=zone1 KEYSPACE=$TARGET_KS TABLET_UID=$TID SHARD="$shard" ./scripts/vttablet-up.sh
    done
  done

  sleep 10

  $LVTCTL InitShardMaster -force $TARGET_KS/-80 zone1-300
  $LVTCTL InitShardMaster -force $TARGET_KS/80- zone1-400
  sleep 2
  echo ">>>>>> Step 9. Calling Reshard"

  $LVTCTL Reshard -tablet_types=MASTER $KSWF "0" "-80,80-"
  if [ $? -eq 1 ]
  then
     echo "Error in Reshard, exiting"
     exit
  fi
  echo ">>>>> Step 4. Waiting for Vreplication to copy the data ..."
  sleep 5
  echo ">>>>> Step 5. Run VDiff "
  $LVTCTL VDiff $KSWF

  echo ">>>>>> Step 6. Calling SwitchReads"
  $LVTCTL SwitchReads -tablet_type=rdonly $KSWF
  $LVTCTL SwitchReads -tablet_type=replica $KSWF
  sleep 5
  echo ">>>>>> Step 7. Calling SwitchWrites"
  $LVTCTL SwitchWrites $KSWF
}


source ./env.sh

mt() {
  setup
  unmanaged
#movetables
}
rs() {
  reshard
}

mt
#rs
