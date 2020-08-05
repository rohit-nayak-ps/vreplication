### SwitchReads

```
SwitchReads  [-cells=<cells>] [-reverse] -tablet_type={replica|rdonly} [-dry-run] <keyspace.workflow>
```

SwitchReads is used to switch reads for tables in a MoveTables workflow or for entire keyspace to the target keyspace in a
Reshard workflow.

Parameters:
 * *-cells* (default: all)

     comma separated list of cells or cell aliases in which reads should be switched in the target keyspace
 * *-tablet_types* (default: all)

     comma separated list of tablet types for which reads should be switched in the target keyspace
 * *-reverse*

     When a workflow is setup the routing rules are setup so that reads/writes to the target shards
     still go to the source shard since the target is not yet setup. If SwitchReads is called without
     -reverse then the routing rules for the target keyspace are setup to actually use it. It is assumed
     that the workflow was successful and user is ready to use the target keyspace now.
     However if, for any reason, we want to abort this workflow using the -reverse flag deletes the
     rules that were setup and vtgate will route the queries to this table to the the source table.
     There is no way to reverse the use of the -reverse flag other than by recreating the routing rules
     again using the vtctl ApplyRoutingRules command.
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
