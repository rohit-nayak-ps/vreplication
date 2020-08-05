# VReplication Command Reference

VReplication has both high-level and low-level commands that let you work with VReplication
workflows. These commands are run by Vitess' administration tool: vtctld.

vtctl is a command-line tool used to administer a Vitess cluster. It is available as
both a standalone tool (vtctl) and client-server (vtctlclient in combination with vtctld).
Using client-server is recommended, as it provides an additional layer of security
when using the client remotely.

A list of some common commands follows. Some commands contain a -dry_run
will reports on what the particular command will do without actually performing the action.

1. [High Level Workflow Commands](#high-level-vreplication-commands)
    1. [MoveTables](#movetables)
    1. [Reshard](#reshard)
    1. [SwitchReads](#switchreads)
    1. [SwitchWrites](#switchwrites)
    1. [VDiff](#vdiff)
    1. [DropSources](#dropsources)
1. [Low Level Workflow Commands](#low-level-vreplication-commands)
    1. [Materialize](#materialize)
    1. [VExec](#vexec)
    1. [Workflow](#workflow)
    1. [VReplicationExec](#vreplicationexec)
1. [Frequently Asked Questions](./faq.md)

## High level VReplication commands

#### MoveTables

```
MoveTables  [-cells=<cells>] [-tablet_types=<source_tablet_types>] -workflow=<workflow>
                                          <source_keyspace> <target_keyspace> <table_specs>
```

MoveTables is used to start a workflow move one or more tables from an external database or an existing Vitess keyspace into a new keyspace. The target keyspace can be unsharded or sharded.

MoveTables is used typically for migrating data into Vitess or to implement vertical partitioning. You might use the former when you
first start using Vitess and the latter if you want to distribute your load across servers.

Parameters:
 * *-cells* (described [here](./common-command-parameters.md#cell))
 * *-tablet_types* (described [here](./common-command-parameters.md#tablet_types))
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

#### SwitchReads

```
SwitchReads  [-cells=<cells>] [-reverse] -tablet_type={replica|rdonly} [-dry-run] <keyspace.workflow>
```

SwitchReads is used to switch reads for tables in a MoveTables workflow or for entire keyspace to the target keyspace in a
Reshard workflow.

Parameters:
 * *-cells*

     comma separated list of cells or cell aliases in which reads should be switched in the target keyspace (default: all)
 * *-tablet_types*

     comma separated list of tablet types for which reads should be switched in the target keyspace (default: all)
 * *-reverse*

         TBD
 * *keyspace.workflow*

    name of target keyspace and the associated workflow

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


#### DropSources

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


TBD: Reshard/VDiff command

## Low level VReplication commands
