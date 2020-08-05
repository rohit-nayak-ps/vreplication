
#### SwitchWrites

```
SwitchWrites  [-filtered_replication_wait_time=30s] [-cancel] [-reverse_replication=true] [-dry-run] <keyspace.workflow>
```

SwitchWrites is used to switch writes for tables in a MoveTables workflow or for entire keyspace in the
Reshard workflow away from the master in the source keyspace to the master in the target keyspace


Parameters:
 * *-filtered_replication_wait_time*

     TBD
 * *-cancel*

     TBD
 * *-reverse_replication*

    TBD
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
