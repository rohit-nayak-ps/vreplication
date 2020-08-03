#VReplication Command Reference

VReplication has both high-level and low-level commands that let you work with VReplication
workflows. These commands are run by Vitess' administration tool: vtctld.

vtctl is a command-line tool used to administer a Vitess cluster. It is available as 
both a standalone tool (vtctl) and client-server (vtctlclient in combination with vtctld).
Using client-server is recommended, as it provides an additional layer of security 
when using the client remotely.

A list of some common commands follows. Many parameters are common across commands.
We document these separately below.

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
1. [Common Command Parameters](#common-command-parameters)
    1. [Tablet Alias](#tablet-alias)
    1. [Cells](#cells)
    1. [Tablet Types](#tablet-types)
    1. [Workflow](#workflow)
    1. [Source Keyspace](#source-keyspace)
    1. [Target Keyspace](#target-keyspace)
    1. [Dry Run](#dry=run)
    



### High level VReplication commands


### Low level VReplication commands


