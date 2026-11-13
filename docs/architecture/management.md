---
title: Management Architecture
description: Administrative access paths and management boundaries for the home lab
---

## Scope

This page describes how administrators reach infrastructure management interfaces. It does not define user access to hosted applications or the detailed authentication configuration of each platform.

## Current State

* The management network is MGMT, `10.0.10.0/24`.
* The OPNsense web interface is hosted on the management network.
* The `bastion` LXC is hosted on the management network.
* The documented management path is through the jump box to the OPNsense web interface.
* Access paths to the Proxmox interface, the k3s administration interfaces, and the physical host are not yet documented.

## Boundaries and Dependencies

* OPNsense controls network reachability to management interfaces.
* The jump box is an access mechanism, not a replacement for firewall policy or identity management.
* Loss of the jump box removes the documented OPNsense access path even if OPNsense and the network remain available.
* Proxmox and k3s administration paths require explicit documentation before automation is introduced.

## Open Questions

* Is Proxmox accessed directly from MGMT, through the jump box, or through another path?
* How will k3s administration be performed?
* Which users and authentication methods are required for each platform?
* Is multi-factor authentication enabled for management interfaces?
* What is the emergency access path if the jump box or OPNsense firewall is unavailable?
* Which current administrative access paths are available if the bastion is unavailable?
