### Reshard

```
Reshard  [-skip_schema_copy] <keyspace.workflow> <source_shards> <target_shards>
```

Reshard support horizontal sharding by letting you change the sharding ranges of your existing keyspace.

Parameters:
 * *-skip_schema_copy* (default: false)

     copies the source schema to the target shards
 * *keyspace.workflow*

    name of target keyspace and the associated workflow
 * *source_shards*

   source shards to migrate to the new target shards
 * *target_shards*

   shards are comma separated shard ids    
