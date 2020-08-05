# VReplication Command Reference

VReplication has both high-level and low-level commands that let you work with VReplication
workflows. These commands are run by Vitess' administration tool: vtctld.

vtctl is a command-line tool used to administer a Vitess cluster. It is available as
both a standalone tool (vtctl) and client-server (vtctlclient in combination with vtctld).
Using client-server is recommended, as it provides an additional layer of security
when using the client remotely.

A list of some common commands follows. Some commands contain a -dry_run
will reports on what the particular command will do without actually performing the action.

1. High Level Workflow Commands
    1. [MoveTables](./movetables.md)
    1. [Reshard](./reshard.md)
    1. [SwitchReads](./switchreads.md)
    1. [SwitchWrites](./switchwrites.md)
    1. [VDiff](./vdiff.md)
    1. [DropSources](./dropsources.md)
1. Low Level Workflow Commands
    1. [Materialize](./materialize.md)
    1. [VExec](./vexec.md)
    1. [Workflow](./workflow.md)
    1. [VReplicationExec](./vreplicationexec.md)
