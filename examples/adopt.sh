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
echo ">>>>>> Step 1: Starting unmanaged tablet"
scripts/unmanaged.sh
sleep 5

echo ">>>>>> Step 2: Starting customer tablets"
for i in 200 201 202;  do
	CELL=zone1 TABLET_UID=$i ./scripts/mysqlctl-up.sh
	CELL=zone1 KEYSPACE=customer TABLET_UID=$i ./scripts/vttablet-up.sh
done

sleep 10

vtctlclient InitShardMaster -force customer/0 zone1-200

sleep 2
echo ">>>>>> Step 3. Calling MoveTables"

vtctlclient MoveTables -tablet_types=MASTER -workflow=commerce2customer commerce customer customer,corder #'{"customer":{}, "corder":{}}'
echo ">>>>> Step 4. Waiting for Vreplication to copy the data ..."
sleep 5
echo ">>>>> Step 5. Run VDiff "
vtctlclient VDiff customer.commerce2customer
echo ">>>>>> Step 6. Calling SwitchReads"
vtctlclient SwitchReads -tablet_type=rdonly customer.commerce2customer
vtctlclient SwitchReads -tablet_type=replica customer.commerce2customer
sleep 5
echo ">>>>>> Step 7. Calling SwitchWrites"
vtctlclient SwitchWrites customer.commerce2customer
vtctlclient VExec commerce.commerce2customer_reverse "select * from _vt.vreplication"

echo ">>>>> Step 8. Run VDiff after inserting data into the customer keyspace"
sleep 15
mysql -h 127.0.0.1 -P 15306 -u msandbox --password=msandbox customer < sql/insert_commerce_data_after_switch.sql

#//BUG: tables customer/corder not found in schema
#exit

vtctlclient VDiff commerce.commerce2customer_reverse

echo "Steps for rolling back"
vtctlclient VExec commerce.commerce2customer_reverse "select * from _vt.vreplication"

echo ">>>>>> Step 9. Rollback SwitchReads"
vtctlclient SwitchReads -tablet_type=rdonly commerce.commerce2customer_reverse
vtctlclient SwitchReads -tablet_type=replica commerce.commerce2customer_reverse
vtctlclient VExec commerce.commerce2customer_reverse "select * from _vt.vreplication"


echo ">>>>>> Step 10. Rollback SwitchWrites"
vtctlclient SwitchWrites commerce.commerce2customer_reverse

echo ">>>>>> Rolled back to original setup. VReplication is still running on Vitess cluster, so you can still move forward ..."


mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce < sql/insert_commerce_data_after_rollback.sql

vtctlclient VDiff customer.commerce2customer

echo ">>>>>>>>> ALL DONE"
