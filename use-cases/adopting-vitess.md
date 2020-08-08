# Migrating data into Vitess using two-way VReplication

We are starting with an existing MySQL installation. We like the Vitess story and want to try it out
while retaining the option of reverting back if we find that it doesn't work out for some reason.

## In a nutshell

### Cutover to Vitess

1. Setup an unmanaged vttablet: a vttablet that connects to your existing MySQL cluster
2. Create a Vitess cluster
3. Initiate a VReplication MoveTables workflow to move all your tables to Vitess
4. Wait for VReplication to migrate all your data and have a low lag with existing MySQL
5. Run VDiff to get confidence that the data in Vitess is identical to the one in MySQL
6. Use the SwitchReads command so that all your reads now go to Vitess
7. Cutover completely to Vitess using SwitchWrites. Vitess will now handle all the write traffic as well as
reads.

At this point if you are confident you can shutdown your MySQL setup. VReplication gives you the option
of delaying this choice until you are absolutely sure and are in production for a while.

### Cutover to MySQL

VReplication, by default, creates a *reverse* replication stream by default so that Vitess is continuously
replicating to the MySQL. So we just need to do a cutover similar to the one we just did above.

8. Run VDiff and confirm that the data in Vitess is also in MySQL
9. Use SwitchReads so that reads are now happening in MySQL
10. Cutover to MySQL by using SwitchWrites so that write traffic is now happening in MySQL


## Details

We will go over the steps which are outlined in the adopt.sh example script. We start that script by cleaning up
any previous processes that are running from this or other examples. _env.sh_ contains various environment variables
required by the vitess commands. This is a good time to review them.

Then the required Vitess processes (etcd: the ology server, vtctld: the Vitess control plane, vtgate: the Vitess sql gateway)
are started.

*Step 1*

I created a MySQL cluster using dbdeployer. Vitess works best with RBR and GTIDs. I added this to
the my.cnf file of the master:
```
binlog_format = row
gtid-mode=ON
enforce-gtid-consistency
log-slave-updates
```
This cluster mimics an external MySQL deployment that we will migrate over to Vitess.
Vitess tablets can either run  *managed* (with its own MySQL server) or *unmanaged* when it
proxies an existing installation. (https://vitess.io/docs/user-guides/unmanaged-tablet/)

The _unmanaged.sh_ script instantiates a vttablet passing it the host/port/credentials to the
dbdeployer cluster.

It requests for the keyspace *commerce* to be created and also a shard *0* to which this
tablet belongs to. This tablet is then made the master of the shard. Tables required for
this example are created and some data inserted. Vitess requires a corresponding VSchema
which is simple in our case since our keyspace is *unsharded* (we only have one shard)
 and hence we don't need a sharding key (vindex).

 *Step 2*

 A new keyspace called *customer* is created. Remember, Step 1 created the *commerce* keyspace.
 The *MySQLctl* binary bundled with Vitess intelligently creates a MySQL server (https://vitess.io/docs/user-guides/configuring-components/#managed-MySQL) and an associated vttablet is also created.

 Three vttablets are created: two replicas and one rdonly tablet. One of them is made the master.

 *Step 3*

 The MoveTables workflow is started. Since the commerce keyspace only has a MASTER we specify that to be the tablet type that can act as a source of data. *commerce2customer* is the workflow name and will be used in subsequent
 commands. We are moving the tables customer and corder from the commerce keyspace (the original installation) to
 the new Vitess customer keyspace.

 *Step 4*

 The time taken to copy the data over depends on the size of the tables. You can follow the progress
 by comparing the outputs of the following query in both commerce and customer.
 ```
 select table_name, table_rows, data_length from information_schema.tables where table_name in ('customer', 'corder')
 ```

As a rule of thumb, huge databases (100s of millions or rows or 100s of GBs) in production have
 taken a few days.

*Step 5*

VDiff does an exact row by row comparison of the target and source databases and reports any mismatches.
VDiff can take hours for huge databases but it gives confidence that the copy was successful and that
no data was lost!

*Step 6*

All Vitess queries are proxied by vtgate. vtgate routes select queries differently from other queries.
For this it uses *routing rules* which are specified in the ology (etcd, in this example).
SwitchReads adds these routing rules and once we have done that any reads done by using the Vitess
connection string ends up using the customer keyspace.

At this point writes are still going to the commerce keyspace and hence to the original MySQL server.

*Step 7*

This step performs the final cutover to Vitess. Writes are also routed to the customer keyspace.

SwitchWrites, by default, starts a reverse replication workflow (in our case, commerce2customer_reverse)
replicating data back to the original source. This is done so that you can rollback easily to
the original installation for any reason.

*Step 8*

To confirm that commerce is still in sync with customer, we insert data into customer via vtgate.
Running VDiff on the reverse workflow proves that there are no mismatches.

*Step 9/10*

Rolling back is similar to the earlier cutover process. We first switch reads back to commerce and then
writes as well.

We are back where we started, expect that the rollback restarts the forward vreplication workflow to
customer. So if there were minor issues to be resolved with the Vitess setup we can do that and then
do the cutover process again.

You can test that by adding data into the original MySQL server and using VDiff to compare with the
data in customer.
