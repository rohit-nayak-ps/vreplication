### Materialize

```
Materialize <json_spec>
```

Materialize is a low level API that allows for generalized materialization of tables. The target tables
can be copies, aggregations or views. The target tables are kept in sync in near-realtime.

You can specify multiple tables to materialize using the json_spec parameter.

#### JSON spec details

* *workflow* name to refer to this materialization
* *source_keyspace* keyspace containing the source table
* *target_keyspace* keyspace to materialize to
* *table_settings* list of materialized views and the associated query
  * *target_table* name of target table which should already exist
  * *source_expression* the materialization query: it can be a 
Note:

There are special commands to perform common materialization tasks and you should prefer them
to using Materialize directly.
* If you just want to copy tables to a different keyspace use MoveTables.
* If you want to change sharding strategies use Reshard instead

Example:

Materialize '{"workflow": "product_sales", "source_keyspace": "commerce", "target_keyspace": "customer", "table_settings": [{"target_table": "sales_by_sku", "source_expression": "select sku, count(*), sum(price) from corder group by order_id"}]}'
