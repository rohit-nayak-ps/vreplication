### MoveTables

```
MoveTables  [-cells=<cells>] [-tablet_types=<source_tablet_types>] -workflow=<workflow>
                                          <source_keyspace> <target_keyspace> <table_specs>
```

MoveTables is used to start a workflow move one or more tables from an external database or an existing Vitess keyspace into a new keyspace. The target keyspace can be unsharded or sharded.

MoveTables is used typically for migrating data into Vitess or to implement vertical partitioning. You might use the former when you
first start using Vitess and the latter if you want to distribute your load across servers.

Parameters:
 * *-cells* (default: local cell)

 A comma separated list of cell names or cell aliases. This list is used by VReplication to determine which
 cells should be used to pick a tablet for sourcing data.

  ***Use Cases***

   * Improve performance by using picking a tablet in cells in network proximity with the target
   * To reduce bandwidth costs by skipping cells which are in different availability zones
   * Select cells where replica lags are lower

 * *-tablet_types* (default: all tablet types)

 A comma separated list of tablet types that are used while picking a tablet for sourcing data.
 One of MASTER,REPLICA,RDONLY.

  ***Use Cases***
    * To reduce load on master tablets by using REPLICAs
    * Reducing lags by pointing to MASTER

 * *-workflow*  

    unique name for the MoveTables-initiated workflow, used in later commands to refer back to this workflows
 * *source_keyspace*

    name of existing keyspace that contains the tables to be moved
 * *target_keyspace*

    name of existing keyspace that contains the tables to be moved

 * *table_specs*

    One of
    * comma separated list of tables (if vschema has been specified for all the tables)
    * JSON table section of the vschema for associated tables in case vschema is not yet specified

TBD: routing rules, blacklisted tables
