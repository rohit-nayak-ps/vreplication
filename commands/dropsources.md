### DropSources

```
DropSources  [-dry_run] [-rename_tables] <keyspace.workflow>
```

Once SwitchWrites has been run DropSources cleans up the source resources by deleting the
source tables for a MoveTables workflow or source shards for a Reshard workflow. It also
cleans up other artifacts of the workflow, deleting forward and reverse replication streams and
blacklisted tables.

*Warning*: This command actually deletes data so it is highly recommended that you run this
with the -dry_run parameter and reads its output so you know which actions will be performed.


Parameters:
 * *-rename_tables* (default: false)

     Only applies for a MoveTables workflow. Instead of deleting the tables in the source it renames them
     by prefixing the tablename with an _ (underscore).
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
