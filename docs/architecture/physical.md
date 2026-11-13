---
title: Physical Architecture
description: Physical Proxmox node and hardware failure boundary for the home lab
---

## Scope

This page describes the physical hardware boundary for the Proxmox nodes on which the virtualized home lab runs. It does not describe guest operating systems, Proxmox configuration, or individual services.

## Current State

The current inventory documents these Proxmox nodes:

| Node   | Status            | Hardware       | Proxmox version                         |
|--------|-------------------|----------------|-----------------------------------------|
| `pve`  | Deployed, running | Bare-metal PC  | VE `9.2.0`, `pve-manager` `9.2.2`       |

* Node `pve` runs an AMD Ryzen 7 8745HS processor with 8 cores and 16 logical CPUs.
* Node `pve` reports 12 GiB of memory and 8 GiB of swap.
* Node `pve` has one 238.5 GiB NVMe disk. Its layout includes a 1 GiB EFI partition, a 237.5 GiB LVM partition, a 69.4 GiB Proxmox root volume, an 8 GiB swap volume, and a 141.2 GiB `pve-data` thin pool.
* The OPNsense VM, k3s VM, and management jump box are currently placed on node `pve`.
* On node `pve`, the primary physical interface `nic0` and bridge `vmbr0` are up. `nic1` and `wlp2s0` are down.
* On node `pve`, the Proxmox bridge `vmbr0` has the static address `192.168.1.143/24`.
* On node `pve`, `vmbr0` is VLAN-aware, uses `nic0` as its bridge port, and permits VLAN IDs `2` through `4094`.
* On node `pve`, the network configuration sets `nic0`, `nic1`, and `wlp2s0` to manual mode and `vmbr0` to static mode.
* The physical network adapters are RJ45 Ethernet ports.
* No UPS or other power protection is present.
* Local console access to node `pve` is available by connecting a keyboard and monitor to the node.
* No Proxmox backup job is currently configured.
* No guest backup jobs are currently configured.
* The exact physical network connections and any out-of-band remote management are not documented.

## Boundaries and Dependencies

* A Proxmox node failure is a failure boundary for the VM and LXC workloads placed on that node. The current inventory places all documented guests on node `pve`.
* Failure of local storage hosting a workload may affect its guest disks, configuration, and local backups at the same time.
* Physical network adapter or switch connectivity is a dependency for every network segment.
* Physical architecture owns node hardware facts and recovery constraints. Guest configuration belongs to the virtualization and platform pages.

## Open Questions

* What are the model and form factor of node `pve`?
* Which physical switch port or network equipment is connected to `nic0`?
* Is any out-of-band remote management available beyond the local keyboard and monitor console?
