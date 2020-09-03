echo ">>>>> Cleaning up previous runs, if any"
./cleanup.sh

source ./env.sh

echo ">>>>>> Starting etcd"
scripts/etcd-up.sh
echo ">>>>>> Starting vtctld"
scripts/vtctld-up.sh
echo ">>>>>> Starting vtgate"
scripts/vtgate-up.sh
sleep 2
echo ">>>>>> Step 1: Starting unmanaged tablet (load1 keyspace)"
scripts/unmanaged_load.sh
sleep 5

echo ">>>>>> Step 2: Starting load2 tablets"
for shard in "0"; do
  for i in 200 201 202;  do
    CELL=zone1 TABLET_UID=$i ./scripts/mysqlctl-up.sh
    CELL=zone1 KEYSPACE=load2 TABLET_UID=$i SHARD=$shard ./scripts/vttablet-up.sh
  done
done

sleep 10

vtctlclient -server localhost:15999 InitShardMaster -force load2/0 zone1-200
sleep 2
vtctlclient -server localhost:15999  MoveTables -tablet_types=MASTER -workflow=wf1 load1 load2 c1
sleep 5
vtctlclient -server localhost:15999  VDiff load2.wf1
exit

sleep 2
echo ">>>>>> Step 3. Calling MoveTables"

vtctlclient MoveTables -tablet_types=MASTER -workflow=wf1 load1 load2 c1
#vtctlclient MoveTables -tablet_types=MASTER -workflow=wf2 load1 load2 table2
#vtctlclient MoveTables -tablet_types=MASTER -workflow=wf3 load1 load2 table3
#vtctlclient MoveTables -tablet_types=MASTER -workflow=wf4 load1 load2 table4

echo ">>>>> Step 4. Waiting for Vreplication to copy the data ..."
sleep 5
echo ">>>>> Step 5. Run VDiff "
vtctlclient VDiff load2.wf
echo ">>>>>> Step 6. Calling SwitchReads"
vtctlclient SwitchReads -tablet_type=rdonly load2.wf
vtctlclient SwitchReads -tablet_type=replica load2.wf
sleep 5
echo ">>>>>> Step 7. Calling SwitchWrites"
vtctlclient SwitchWrites load2.wf
