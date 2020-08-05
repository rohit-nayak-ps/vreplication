#Command Line Parameters common to multiple VReplication Commands

Note: due to backward compatibility reasons or historical reasons some parameters have different names. We are
in the process of adding uniformity. The alternative names used are mentioned against each parameter.

### -cells

***Synonyms*** *-cell* or *-cells_to_watch*

***Default*** cell local to target

***Description***
A comma separated list of cell names or cell aliases. This list is used by VReplication to determine which
cells should be used to pick a tablet for sourcing data. Usually used in conjunction with [tablet_types](#tablet_types)

***Use Cases***

* Improve performance by using picking a tablet in cells in network proximity with the target
* To reduce bandwidth costs by skipping cells which are in different availability zones
* Select cells where replica lags are lower

### -tablet_types

***Synonyms*** *-tablet_type*
***Default*** replica

***Description***
A comma separated list of tablet types that are used while picking a tablet for sourcing data.
One of MASTER,REPLICA,RDONLY.
 Usually used in conjunction with [cells](#cells)

***Use Cases***
* To reduce load on master tablets by using REPLICAs
* Reducing lags by pointing to MASTER

### -dry_run

***Default*** false

***Description***

Self evident: reports on what the particular command will do without actually performing the action.
