# Migrating data into Vitess using two-way VReplication

Here we are starting with an existing MySQL installation. We like the Vitess story and want to try it out
while retaining the option of reverting back if we find that it doesn't work for us for any reason.

## In a nutshell

### Cutover to Vitess

1. Setup an unmanaged vttablet: a vttablet that connects to your existing MySQL cluster
1. Create a Vitess cluster 
1. Initiate a VReplication MoveTables workflow to move all your tables to Vitess
1. Wait for VReplication to migrate all your data and have a low lag with existing MySQL 
1. Run VDiff to get confidence that the data in Vitess is identical to the one in MySQL
1. Use the SwitchReads command so that all your reads now go to Vitess
1. Cutover completely to Vitess using SwitchWrites. Vitess will now handle all the write traffic as well as
reads.

At this point if you are confident you can shutdown your MySQL setup. VReplication gives you the option
of delaying this choice until you are absolutely sure and are in production for a while.

### Rollback from Vitess

VReplication, by default, creates a *reverse* replication stream by default so that Vitess is continuously
replicating to the MySQL. So we just need to do a cutover similar to the one we just did above.

1. Run VDiff and confirm that the data in Vitess is also in MySQL
1. Use SwitchReads so that reads are now happening in MySQL
1. Cutover to MySQL by using SwitchWrites so that write traffic is now happening in MySQL


## Details




(https://vitess.io/docs/user-guides/unmanaged-tablet/)