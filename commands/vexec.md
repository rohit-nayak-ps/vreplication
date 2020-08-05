### VExec

```
VExec  [-dry_run] <keyspace.workflow> <query>
```

VExec is a wrapper over [VReplicationExec](https://vitess.io/docs/reference/features/vreplication/#vreplicationexec).
Given a workflow it executes the provided query on all masters in the target keyspace that participate
in the workflow. Internally it calls VReplicationExec for running the query.

Parameters:
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
 * *query*

    query to be executed on all shard masters
