#start afresh processes and db
./cleanup.sh
mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce < sql/create_commerce_schema.sql
mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce < sql/insert_commerce_data.sql


#asciinema demo starts
source ./env.sh
mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce  -e "select * from corder;select * from customer;select * from product;"

# start topology, vtctld and vtgate
scripts/etcd-up.sh
scripts/vtctld-up.sh
scripts/vtgate-up.sh

#Start unmanaged tablet in keyspace commerce
scripts/unmanaged.sh

#Start vitess cluster in keyspace customer
for i in 200 201 202;  do
	CELL=zone1 TABLET_UID=$i ./scripts/mysqlctl-up.sh
	CELL=zone1 KEYSPACE=customer TABLET_UID=$i ./scripts/vttablet-up.sh
done

vtctlclient InitShardMaster -force customer/0 zone1-200

# start vreplication workflow
vtctlclient MoveTables -tablet_types=MASTER -workflow=commerce2customer commerce customer customer,corder

# use vdiff to confirm replication has taken plae
vtctlclient VDiff customer.commerce2customer

# insert row and show that we are syncing
vtctlclient VExec customer.commerce2customer "select id,workflow,state,pos from _vt.vreplication"

mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce  -e "insert into customer(email) values ('kubecon@a.com');"
vtctlclient VExec customer.commerce2customer "select id,workflow,state,pos from _vt.vreplication"


echo ">>>>>> Step 6. Calling SwitchReads"
vtctlclient SwitchReads -tablet_type=rdonly customer.commerce2customer
vtctlclient SwitchReads -tablet_type=replica customer.commerce2customer
sleep 5
echo ">>>>>> Step 7. Calling SwitchWrites"
vtctlclient SwitchWrites customer.commerce2customer



vtctlclient VExec commerce.commerce2customer_reverse "select id,workflow,state,pos from _vt.vreplication"

echo ">>>>> Step 8. Run VDiff after inserting data into the customer keyspace"
sleep 15
mysql -h 127.0.0.1 -P 15306 -u msandbox --password=msandbox customer < sql/insert_commerce_data_after_switch.sql


echo "Steps for rolling back"
vtctlclient VExec commerce.commerce2customer_reverse "select id,workflow,state,pos from _vt.vreplication"

echo ">>>>>> Step 9. Rollback SwitchReads"
vtctlclient SwitchReads -tablet_type=rdonly commerce.commerce2customer_reverse
vtctlclient SwitchReads -tablet_type=replica commerce.commerce2customer_reverse

echo ">>>>>> Step 10. Rollback SwitchWrites"
vtctlclient SwitchWrites commerce.commerce2customer_reverse

echo ">>>>>> Rolled back to original setup. VReplication is still running on Vitess cluster, so you can still move forward ..."


mysql -h 127.0.0.1 -P 19327 -u msandbox --password=msandbox commerce < sql/insert_commerce_data_after_rollback.sql

vtctlclient VDiff customer.commerce2customer

echo ">>>>>>>>> ALL DONE"
