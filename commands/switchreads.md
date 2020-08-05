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

         TBD
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
