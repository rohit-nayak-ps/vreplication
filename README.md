# Notes on VReplication

Copyright 2020 &copy; Vitess Authors


## Table Of Contents
1. [Introduction](#)
    1. [Status](#introduction)
    1. [Intended Audience](#intended-audience)
    1. [What is VReplication](#what-is-vreplication)
1. [Terminology and Key Concepts](./misc/concepts.md)
1. [Common Use Cases](./common-use-cases.md)
    1. [Adopting Vitess](./use-cases/adopting-vitess.md)
    1. [Vertical Resharding](./use-cases/vertical-resharding.md)
    1. [Horizontal Resharding](./use-cases/horizontal-resharding.md)
    1. [Change Data Capture](./use-cases/change-data-capture.md)
1. [Command Reference](./commands/commands.md)
1. [TBD: Performance and Scalability](./misc/scalability.md)
1. [Internals](./misc/internals.md)
1. [Frequently Asked Questions](./misc/faq.md)

---
### Introduction

In this guide we will be introducing the terminology used while talking about VReplication, giving a few real-life examples where it can be used and also delving into its internals.

VReplication has several use-cases and many of the standard use-cases have advanced usage. The intent is to
first document the more common and popular use-cases.

This document should be considered a work-in-progress documentation. For reasons of agility we provide
this in the vitess contrib. VReplication is young and will be seeing a lot of activity: we will
try our best to update these docs to reflect the latest functionality.

Suggestions, Improvements, bug reports/fixes will be gratefully accepted either as pull requests or comments
in the #vreplication slack channel :-)

This guide is for the "new" v3 VReplication implementation and is not to be confused with the previous workflows (which are
  now deprecated) like SplitClone and VerticalSplitClone.

### Intended Audience

This document is primarily intended for developers: both early adopters and intermediate users of Vitess who want to start using VReplication workflows.

Readers are expected to be familiar with Vitess concepts and should have at the least got the local example setup and working.

We will also delve into sufficient detail about how VReplication works internally. This is intended for power users who would like to understand the guarantees provided in terms of consistency, pointers to debugging related operational issues as well as getting an idea of the performance implications of using the different VReplication workflows.

While we will attempt to keep this document in sync with code changes, the docs at [https://vitess.io/docs/](https://vitess.io/docs/) continue to be the authoritative reference.

### What is VReplication

Sharding introduces a whole new set of challenges for SREs and application developers. Traditional tools don’t work well and you end up needing to write and maintain your own toolbox of scripts and bespoke code. VReplication was created to handle many of the standard workflows needed to manage common Day 2 requirements based on experience with very large Vitess clusters containing thousands of mysql instances.

VReplication is the mechanism within Vitess to transfer data from or to shards. It uses a combination of vstreams to achieve the purpose. Let us look at a couple of examples:

1. _Resharding_ When you ask Vitess to reshard, under the hood it is VReplication which creates vstreams on the VTTablets of the target shards. These streams copy data from the source shards to the target shards with splitting/merging of data as per the old and new sharding configurations
2. _Change Data Capture_. When you ask VTGate to stream binlogs from keyspaces by invoking the VStream API, VTGate creates appropriate vstreams and combines them.

At one point or the other, most Vitess users will end up using functionality that is provided using VReplication. Thus VReplication is a core part of Vitess and understanding it well will help you as you manage and operate Vitess and to also make the most of its features.

VReplication can be used at different levels:

* Vitess adopters can use VReplication to migrate their data into Vitess from their current MySQL setup
in a risk-free manner.
VReplication can keep the Vitess installation in sync with their existing setup allowing them to cutover to using Vitess in production
while retaining the ability to rollback to the existing setup.  

* Existing vitess users can use VReplication for horizontal and vertical resharding, create materialized
views or aggregated rollups to speed up queries. VReplication also makes it easy to export data to
Change Data Capture systems like Debezium or data lake implementations.

* Advanced user may also like to use VReplication to backfill lookup indexes or for schema deployment.
