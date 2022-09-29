source env.sh
setup(){
  echo ">>>>> Cleaning up previous runs, if any"
  ./cleanup.sh

  MYSQL_PORT=21122
  echo ">>>>>> Starting etcd"
  scripts/etcd-up.sh
  echo ">>>>>> Starting vtctld"
  scripts/vtctld-up.sh
  echo ">>>>>> Starting vtgate"
  scripts/vtgate-up.sh
  sleep 2
  mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox test -e "drop database if exists _vt"
  mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox test -e "drop database if exists load2"
  mysql -h 127.0.0.1 -P 21122 -u msandbox --password=msandbox test -e "create database load2 CHARACTER SET utf8mb4 collate utf8mb4_general_ci"
  echo "setup done"
}

unmanagedSource(){
  echo ">>>>>> Step 1: Starting unmanaged tablet (load1 keyspace)"
  scripts/unmanaged_load_57.sh #rsandbox_5_7_26
  sleep 5
  echo "Unmanaged Source mysql 57 done"

  # echo ">>>>>> Step 1: Starting unmanaged tablet (load2 keyspace)"
  # scripts/unmanaged_aws1.sh
  # sleep 5
}

unmanagedTarget(){
  echo ">>>>>> Step 1: Starting unmanaged tablet (load1 keyspace)"
  scripts/unmanaged_load_80.sh #rsandbox_5_7_26
  sleep 5
  echo "Unmanaged Source mysql 80 done"
}

mat() {
  setup
  unmanaged

  spec_template="\"{\'workflow\': \'mat\',\'sourceKeyspace\': \'load1\',\'targetKeyspace\': \'load2\',\'tableSettings\': [{\'targetTable\': \'x_XXX\',\'sourceExpression\': \'select id from x\',\'create_ddl\': \'create table x_XXX(id int, primary key(id))\'}]}\""

  for t in {1..1}
  do
    spec=${spec_template/XXX/$t}
    echo "spec is $spec"
    $LVTCTL Materialize ${spec}
    if [ $? -eq 1 ]
    then
       echo "Error in Materialize, exiting"
       exit
    fi
  done
}


movetables(){
  echo ">>>>>> Step 2: Starting load2 tablets"
  if [ 0 -eq 0 ] # change to always false if we want to use an unmanaged tablet (say aws) as target
  then
    for shard in "0"; do
      for i in 200 201 202;  do
        CELL=zone1 TABLET_UID=$i ./scripts/mysqlctl-up.sh
        CELL=zone1 KEYSPACE=load2 TABLET_UID=$i SHARD=$shard ./scripts/vttablet-up.sh
      done
    done

    sleep 10

    #$LVTCTL InitShardPrimary -force load2/0 zone1-200
    sleep 2
  fi

  echo ">>>>>> Step 3. Calling MoveTables"
  TABLE=c1m
  WORKFLOW=mt
  SOURCE_KS=load1
  TARGET_KS=load2
  KSWF=$TARGET_KS.$WORKFLOW
  $LVTCTL MoveTables -source $SOURCE_KS -tables $TABLE Create $TARGET_KS.$WORKFLOW
  if [ $? -eq 1 ]
  then
     echo "Error in MoveTables, exiting"
     exit
  fi
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
  $LVTCTL VDiff -v2 -tablet_types=replica $KSWF
  return

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

movetables2() {
  WORKFLOW=mts
  SOURCE_KS=load1
  TARGET_KS=load2
  KSWF="$TARGET_KS.$WORKFLOW"
  TABLES=c10,c1m
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

  $LVTCTL InitShardPrimary -force $TARGET_KS/-80 zone1-300
  $LVTCTL InitShardPrimary -force $TARGET_KS/80- zone1-400
  sleep 2

  echo ">>>>>>>> applying schema/vschema"
  $LVTCTL ApplyVSchema -vschema_file sql/load2_sharded_vschema.json $TARGET_KS
  $LVTCTL RebuildVSchemaGraph -cells=zone1

  $LVTCTL MoveTables -source $SOURCE_KS -tables $TABLES Create $TARGET_KS.$WORKFLOW

  $LVTCTL VDiff load2.mts
  $LVTCTL VDiff --v2 load2.mts
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

  #$LVTCTL InitShardPrimary -force $TARGET_KS/-80 zone1-300
  #$LVTCTL InitShardPrimary -force $TARGET_KS/80- zone1-400
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

unmanagedMoveTables() {
  setup
  unmanagedSource
  unmanagedTarget
  echo "Starting MoveTables"
  $LVTCTL MoveTables  -source load1 -tables c10 Create load2.mt1
  # echo "Sleeping"
  # sleep 10
  # echo "VDiff v1"
  # $LVTCTL VDiff load2.mt1
  # echo "VDiff v2"
  # $LVTCTL VDiff --v2 load2.mt1 Create
}

mt() {
  setup
  unmanagedSource
  movetables2
}
rs() {
  reshard
}
mts() {
  setup
  unmanaged
  movetables2
}

#unmanagedMoveTables
mt
