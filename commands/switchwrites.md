
#### SwitchWrites

```
SwitchWrites  [-filtered_replication_wait_time=30s] [-cancel] [-reverse_replication=true] [-dry-run] <keyspace.workflow>
```

SwitchWrites is used to switch writes for tables in a MoveTables workflow or for entire keyspace in the
Reshard workflow away from the master in the source keyspace to the master in the target keyspace


Parameters:
 * *-filtered_replication_wait_time* (default: 30s)

     SwitchWrites first stops writes on the source master and waits for the replication to the target to
     catchup with the point where the writes were stopped. If the wait time is longer than filtered_replication_wait_time
     the command will error out.
 * *-cancel* (default: false)

     If a previous SwitchWrites returned with an error you can restart it by running the command again (after fixing
     the issue that caused the failure) or the SwitchWrites can be canceled using this parameter. Only the SwitchWrites
     is cancelled: the workflow is set to Running so that replication continues.
 * *-reverse_replication* (default: true)

     SwitchWrites, by default, starts a reverse replication stream with the current target as the source, replicating
     back to the original source. This enables a quick and simple rollback. This reverse workflow name is that
     of the original workflow concatenated with \_reverse.

 * *keyspace.workflow*

    name of target keyspace and the associated workflow
