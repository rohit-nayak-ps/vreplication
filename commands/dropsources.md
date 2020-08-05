### DropSources

```
DropSources  [-dry_run] [-rename_tables] <keyspace.workflow>
```

Once SwitchWrites has been run DropSources cleans up the source resources by deleting the
source tables for a MoveTables workflow or source shards for a Reshard workflow.

*Warning*: This command actually deletes data so it is highly recommended that you run this
with the -dry_run parameter and reads its output so you know which actions will be performed.


Parameters:
 * *-filtered_replication_wait_time*

     TBD
 * *-cancel*

     TBD
 * *-reverse_replication*

    TBD
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
