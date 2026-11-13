---
title: Service Placement Architecture
description: Placement and exposure rules for infrastructure and hosted services
---

## Scope

This page defines where categories of services belong. Individual k3s applications should have their own documentation under a deeper service directory once they are identified.

## Current State

| Category             | Placement                 | Status   | Exposure            |
|----------------------|---------------------------|----------|---------------------|
| Firewall and routing | OPNsense VM               | Deployed | Internal management |
| Management access    | Jump box LXC in MGMT      | Deployed | Administration      |
| Kubernetes platform  | k3s VM in SERVERS         | Deployed | Cluster-internal    |

No individual application inventory has been created yet.

## Boundaries and Dependencies

* Current placement depends on network exposure, persistence, backup requirements, operational complexity, and platform compatibility.
* A k3s service depends on the cluster platform, its namespace policies, storage, DNS, and any external dependencies.
* Application details belong in service-specific documentation, not in this placement overview.

## Open Questions

* Which applications are currently deployed in the K3s cluster?
* Which deployed services need persistent storage or databases?
* Which current services run outside Kubernetes?
* Which deployed applications are externally reachable?
* What backup and recovery objectives apply to each stateful service?
* What naming convention will identify services across documentation, DNS, and configuration?
