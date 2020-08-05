### Workflow

```
Workflow  [-dry_run] <keyspace[.workflow]> <action>
```

Workflow is a convenience command that some common functions associated with a workflow.  

Parameters:
 * *keyspace.workflow*

    name of target keyspace and the associated workflow. All except the list-all action require workflow.
 * *action*

    action is one of
    * *stop* sets the state of the workflow to Stopped, no further vreplication will happen until restarted
    * *start* starts a Stopped workflows
    * *delete* removes the entries for this workflow in \_vt.vreplication
    * *list* returns a JSON object with details about the associated shards and also with all the columns
    from the \_vt.vreplication table
    * *list-all* returns a list of all running workflows in a keyspace
