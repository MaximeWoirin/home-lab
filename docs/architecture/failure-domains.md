---
title: Failure Domains
description: Availability limits, single points of failure, and recovery priorities for the home lab
---

## Scope

This page identifies the current failure domains and their impact. It is an architectural baseline, not a complete disaster recovery procedure.

## Current State

The lab is concentrated on one physical host and does not currently have a high-availability design.

No Proxmox backup job is currently configured. External backup coverage is not documented.

| Domain              | Impact                   | Redundancy             | Recovery                  |
|---------------------|--------------------------|------------------------|---------------------------|
| Bare-metal host     | All guests offline       | None documented        | Restore host              |
| Proxmox platform    | Guest lifecycle offline  | None documented        | Restore Proxmox           |
| OPNsense VM         | Routing and firewalling  | None documented        | Restore OPNsense          |
| k3s VM              | Cluster workloads        | None documented        | Restore VM and data       |
| Jump box LXC        | Management path          | No alternate documented | Use emergency access      |

The single-node or multi-node topology inside the k3s VM is not yet documented. In either case, the VM and physical host remain failure boundaries.

## Current Recovery Dependencies

The current recovery dependency order is:

1. Physical host, Proxmox, and storage
2. OPNsense and core network connectivity
3. Management access through the jump box or an emergency path
4. k3s VM and cluster platform

## Boundaries and Dependencies

* OPNsense is a shared dependency for communication between the defined network segments.
* Recovery documentation must identify which configuration is authoritative and where each backup is stored.

## Open Questions

* What are the recovery time and recovery point objectives for the host, firewall, cluster, and services?
* Are any backups taken outside Proxmox, and are they stored outside the physical host?
* How is an OPNsense configuration restored without the normal management path?
* How is persistent k3s data backed up and restored?
* What services are critical enough to justify separate recovery procedures?
