---
title: Networking Architecture
description: Network segments, trust boundaries, and deployed traffic flows for the home lab
---

## Scope

This page describes the deployed logical network segments and their relationships. Concrete interfaces, firewall rules, routes, and aliases belong in the OPNsense configuration.

## Current State

OPNsense is the network and security boundary. The gateway address is `.1` in each deployed segment.

| Segment | Network        | Gateway      | Status   | Purpose                    |
|---------|----------------|--------------|----------|----------------------------|
| MGMT    | `10.0.10.0/24` | `10.0.10.1`  | Deployed | Management and bastion      |
| SERVERS | `10.0.30.0/24` | `10.0.30.1`  | Deployed | K3s and server services     |

The exact VLAN, bridge, interface, DHCP, DNS, and firewall implementation is not yet documented.

## Boundaries and Dependencies

* OPNsense owns gateway addresses, routing, firewall policy, and network-level name services when enabled.
* Proxmox owns the virtual network attachment of each guest.
* k3s owns service networking inside the cluster.
* Network intent must be coordinated with [service placement](service-placement.md) and the OPNsense platform documentation.

## Open Questions

* Are these segments implemented as VLANs, Proxmox bridges, or another virtual networking model?
* Which physical and virtual interfaces carry each segment?
* Which services provide DHCP and DNS for each segment?
* Which exact flows are currently required between MGMT and SERVERS?
* Which deployed services provide DHCP and DNS?
