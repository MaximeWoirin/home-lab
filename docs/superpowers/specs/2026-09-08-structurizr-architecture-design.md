---
title: Structurizr Architecture Design
description: Design for a local, version-controlled C4 model of the deployed home lab
---

## Scope

Introduce a Structurizr DSL workspace as the visual architecture source for the
deployed home lab. The workspace is rendered locally through a Docker-based
runner and is not deployed to the home-lab infrastructure.

## Goals

* Keep the C4 model in version control as readable DSL
* Render the model locally without a hosted Structurizr service
* Model only deployed and verified infrastructure
* Provide consistent context, platform, network, and deployment views
* Preserve existing Markdown architecture pages as factual reference material

## Workspace Structure

The repository will add an `architecture/` directory containing:

| File | Responsibility |
|------|----------------|
| `architecture/workspace.dsl` | Canonical Structurizr model, views, and styles |
| `architecture/compose.yaml` | Local-only Docker service for the Structurizr viewer |
| `architecture/README.md` | Commands to render and validate the workspace |

## Model

The first workspace models one deployed system, the home lab, and one person,
the administrator. It contains the following verified platform containers:

* Proxmox VE on node `pve`
* OPNsense, deployed as VM `100`
* The `bastion` management LXC, deployed as ID `101`
* The k3s cluster VM, deployed as ID `102`

The model identifies MGMT, `10.0.10.0/24`, and SERVERS, `10.0.30.0/24`, as
infrastructure elements. OPNsense is the router and security boundary for both
segments. The model must not assign VLAN IDs to a segment other than the
documented Proxmox guest tags, or claim unverified firewall flows.

## Views

| View | Purpose |
|------|---------|
| System context | Show the administrator and the home-lab system boundary |
| Platform | Show Proxmox VE, OPNsense, bastion, and k3s responsibilities and relationships |
| Network | Show MGMT, SERVERS, and OPNsense as the gateway and security boundary |
| Deployment | Show the physical `pve` host and the deployed VM and LXC placements |

No application-placement elements are included because the deployed k3s
application inventory is not documented.

## Local Operation

The Compose service exposes the viewer only on `127.0.0.1`. Its bind mount
provides the repository workspace to the local Structurizr process. The README
will document the Docker Compose command to start the viewer and the command to
validate the DSL. No infrastructure apply, firewall change, or external service
is part of this change.

## Validation

Validation must prove that the Structurizr DSL parses successfully and that the
Compose file resolves. It must not require connection to the deployed home lab.

## Out Of Scope

* Deploying Structurizr into the home lab
* Modeling undocumented individual k3s applications
* Replacing existing Markdown documentation
* Changing OPNsense, Proxmox, k3s, or network configuration