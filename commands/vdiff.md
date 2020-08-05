### VDiff

```
VDiff  [-source_cell=<cell>] [-target_cell=<cell>] [-tablet_types=replica]
                          [-filtered_replication_wait_time=30s] <keyspace.workflow>
```

VDiff does a row by row comparison of all tables associated with the workflow, diffing the
source keyspace and the target keyspace and reporting counts of missing/extra/unmatched rows.

It is highly recommended that this be done before you finalize a workflow with SwitchWrites.

***Notes***
 * VDiff can take very long (days) for huge tables, so this needs to be taken into account.
 * There is no throttling, so you might see an increased lag in the replica used as the source
Planned VReplication and VDiff performance improvements as well as freno-style throttling support are on the roadmap!

Parameters:
 * *-source_cell* (default: all)

     VDiff will choose a tablet from this cell to diff the source table(s) with the target tables
 * *-target_cell* (default: all)

     VDiff will choose a tablet from this cell to diff the target table(s) with the source tables
 * *-tablet_types* (default: REPLICA)

    VDiff will choose a tablet of these types to diff the source table(s) with the target tables
 * *-filtered_replication_wait_time* (default 30s)

     VDiff first chooses a tablet and then, if the tablet is not the master, waits for the tablet to
     reach the current GTID position of the master. If it takes longer than filtered_replication_wait_time
     VDiff errors out.
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
