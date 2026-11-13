---
title: Virtualization Architecture
description: Proxmox, VM, and LXC placement for the home lab
---

## Scope

This page describes how workloads are placed across Proxmox nodes. It focuses on workload boundaries and placement, not on guest-specific configuration.

## Current State

Proxmox VE `9.2.0` is the virtualization platform currently documented on node `pve`. The installed Proxmox manager version is `9.2.2`.

| Workload      | Proxmox name | Proxmox node | Form | ID  | Status            | CPU          | Memory / storage   | Network | Role               |
|---------------|--------------|--------------|------|-----|-------------------|--------------|--------------------|---------|--------------------|
| OPNsense      | `OPNsense`   | `pve`        | VM   | 100 | Deployed, running | Not reported | 4096 MiB / 40 GiB  | All     | Firewall and router |
| k3s cluster   | `K3s`        | `pve`        | VM   | 102 | Deployed, running | Not reported | 8112 MiB / 64 GiB   | SERVERS | Kubernetes cluster  |
| Jump box      | `bastion`    | `pve`        | LXC  | 101 | Deployed, running | 1 core       | 64 MiB / 1 GiB     | MGMT    | Management access   |

The storage inventory exposes these guest volume names:

| Volume          | Size   | Mapping                |
|-----------------|--------|------------------------|
| `vm-100-disk-0` | 40 GiB | OPNsense VM, ID `100`  |
| `vm-101-disk-0` | 1 GiB  | bastion LXC, ID `101`  |
| `vm-102-disk-0` | 64 GiB | K3s VM, ID `102`       |

The current Proxmox network attachments are:

| Workload | Proxmox interface | Bridge  | VLAN tag       | Documented segment |
|----------|-------------------|---------|----------------|--------------------|
| OPNsense | `net0`            | `vmbr0` | Not configured | All                |
| K3s      | `net0`            | `vmbr0` | `30`           | SERVERS            |
| bastion  | `net0` / `eth0`   | `vmbr0` | `10`           | MGMT               |

* No guest boot priorities or restart policies are configured.
* No guest backup jobs are currently configured.

| Storage     | Proxmox node | Type    | Status | Content                     | Total (KiB) |
|------------|--------------|---------|--------|-----------------------------|-------------|
| `local`    | `pve`        | dir     | active | import, iso, backup, vztmpl | 71017632    |
| `local-lvm`| `pve`        | lvmthin | active | images, rootdir             | 148086784   |

## Boundaries and Dependencies

* Proxmox owns guest lifecycle, virtual hardware, resource allocation, storage attachment, virtual network attachment, and placement across nodes.
* OPNsense owns routing and traffic policy between guest networks.
* Guest operating systems own their internal services and configuration.
* A Proxmox node failure is a failure boundary for workloads placed on that node. The current inventory places all documented workloads on node `pve`.
* The current logical recovery dependency includes the Proxmox node hosting each workload, OPNsense, management access, and K3s.
* Detailed configuration belongs in [Proxmox documentation](../../proxmox/) and the relevant platform directory.

## Open Questions

No virtualization inventory questions are currently documented.
