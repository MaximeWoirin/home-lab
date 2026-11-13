---
title: Architecture Documentation
description: Index and conventions for the home-lab architecture documentation
---

## Purpose

These pages describe the home lab in layers. Each page answers one architectural question and links to deeper or more operational documentation when needed.

## Reading Order

1. [Physical architecture](physical.md) describes the bare-metal failure boundary.
2. [Virtualization architecture](virtualization.md) describes Proxmox and its guests.
3. [Networking architecture](networking.md) describes segments, trust boundaries, and intended flows.
4. [Management architecture](management.md) describes the administrative access path.
5. [Service placement](service-placement.md) describes where infrastructure and applications belong.
6. [Failure domains](failure-domains.md) describes availability limits and recovery priorities.

## Documentation Pattern

Each architecture topic page uses the same sections:

* Scope defines the question answered by the page.
* Current State records deployed or verified facts.
* Boundaries and Dependencies identifies ownership and relationships with other layers.
* Open Questions records information that must be verified before automation or live changes.

Use verified facts only. Record missing current details as open questions and do not describe unbuilt components. Keep implementation details in the owning configuration directory and link to them from these pages instead of duplicating them.
