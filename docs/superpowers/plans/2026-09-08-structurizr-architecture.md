---
title: Structurizr Architecture Implementation Plan
description: Implementation steps for the local C4 architecture workspace
---

## Structurizr Architecture Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a locally rendered, version-controlled Structurizr C4 model for
the deployed home lab.

**Architecture:** A single `workspace.dsl` models the administrator, home-lab
platform, verified network segments, and workload deployment. Docker Compose
uses the current Structurizr local image and binds it to localhost. Existing
Markdown remains the detailed factual reference.

**Tech Stack:** Structurizr DSL, Structurizr local Docker image, Docker Compose

---

## File Structure

| File | Responsibility |
|------|----------------|
| `architecture/workspace.dsl` | Canonical C4 model, views, and styles |
| `architecture/compose.yaml` | Local-only Structurizr viewer |
| `architecture/README.md` | Local start, validation, and layout workflow |

### Task 1: Create the Structurizr Workspace

**Files:**

* Create: `architecture/workspace.dsl`

- [ ] **Step 1: Write the workspace DSL**

```structurizr
workspace "Home Lab Architecture" "C4 model for the deployed home lab." {
    model {
        administrator = person "Home Lab Administrator" "Administers the home lab."

        homeLab = softwareSystem "Home Lab" "Self-hosted infrastructure platform." {
            proxmox = container "Proxmox VE" "Virtualization platform running on node pve." "Proxmox VE 9.2.0"
            opnsense = container "OPNsense" "Firewall, router, and network security boundary." "OPNsense"
            bastion = container "Management Bastion" "Jump box for management access." "LXC"
            k3s = container "k3s Cluster" "Kubernetes platform for server services." "k3s"
        }

        managementNetwork = element "MGMT" "Management network, 10.0.10.0/24." "Network Segment"
        serversNetwork = element "SERVERS" "Server-services network, 10.0.30.0/24." "Network Segment"

        administrator -> bastion "Uses for management access"
        bastion -> opnsense "Accesses the web interface"
        proxmox -> opnsense "Hosts as VM 100"
        proxmox -> bastion "Hosts as LXC 101"
        proxmox -> k3s "Hosts as VM 102"
        opnsense -> managementNetwork "Provides gateway 10.0.10.1"
        opnsense -> serversNetwork "Provides gateway 10.0.30.1"
        bastion -> managementNetwork "Connected to"
        k3s -> serversNetwork "Connected to"

        production = deploymentEnvironment "Home Lab" {
            pve = deploymentNode "pve" "Bare-metal PC running Proxmox VE." "Proxmox VE 9.2.0" {
                opnsenseVm = deploymentNode "OPNsense VM" "Virtual machine ID 100." "Virtual Machine" {
                    containerInstance opnsense
                }
                bastionLxc = deploymentNode "bastion LXC" "Container ID 101." "Linux Container" {
                    containerInstance bastion
                }
                k3sVm = deploymentNode "k3s VM" "Virtual machine ID 102." "Virtual Machine" {
                    containerInstance k3s
                }
            }
        }
    }

    views {
        systemContext homeLab "SystemContext" "Home lab context." {
            include administrator
            include homeLab
            autoLayout lr
        }

        container homeLab "Platform" "Home lab platform responsibilities." {
            include *
            autoLayout lr
        }

        custom "Network" "Network segmentation." {
            include opnsense
            include managementNetwork
            include serversNetwork
            include bastion
            include k3s
            autoLayout lr
        }

        deployment homeLab production "Deployment" "Home lab workload placement." {
            include *
            autoLayout lr
        }

        styles {
            element "Person" {
                shape person
                background "#084c61"
                color "#ffffff"
            }
            element "Software System" {
                background "#177e89"
                color "#ffffff"
            }
            element "Container" {
                background "#00a6a6"
                color "#ffffff"
            }
            element "Network Segment" {
                shape roundedBox
                background "#f4d35e"
                color "#1f2933"
            }
            element "Deployment Node" {
                background "#e6e9ed"
                color "#1f2933"
            }
        }
    }
}
```

- [ ] **Step 2: Validate the workspace**

Run:

```bash
docker run --rm -v "$PWD:/workspace:ro" structurizr/structurizr@sha256:251905a1a2d73195e84b784966babc71b329223fdbb25368261a9e3ba39041c4 validate -workspace /workspace/architecture/workspace.dsl
```

Expected: exit code `0` with no DSL parser errors.

### Task 2: Add the Local Docker Runner

**Files:**

* Create: `architecture/compose.yaml`

- [ ] **Step 1: Add the Compose service**

```yaml
services:
  structurizr:
    image: structurizr/structurizr@sha256:251905a1a2d73195e84b784966babc71b329223fdbb25368261a9e3ba39041c4
    command: local
    ports:
      - "127.0.0.1:8080:8080"
    volumes:
      - ./:/usr/local/structurizr
```

- [ ] **Step 2: Validate the Compose configuration**

Run:

```bash
docker compose -f architecture/compose.yaml config --quiet
```

Expected: exit code `0`.

- [ ] **Step 3: Start the local viewer**

Run:

```bash
docker compose -f architecture/compose.yaml up -d
curl --fail --silent --show-error http://127.0.0.1:8080/ > /dev/null
```

Expected: the viewer responds on `127.0.0.1:8080`.

- [ ] **Step 4: Stop the local viewer**

Run:

```bash
docker compose -f architecture/compose.yaml down
```

Expected: the local container is removed.

### Task 3: Document the Local Workflow

**Files:**

* Create: `architecture/README.md`

- [ ] **Step 1: Document the local viewer and validation commands**

````markdown
## Run Locally

```bash
docker compose -f architecture/compose.yaml up
```

Open <http://127.0.0.1:8080> to view the workspace.

## Validate

```bash
docker run --rm -v "$PWD:/workspace:ro" structurizr/structurizr@sha256:251905a1a2d73195e84b784966babc71b329223fdbb25368261a9e3ba39041c4 validate -workspace /workspace/architecture/workspace.dsl
```

## Save Layout Changes

The local editor writes diagram layouts to `architecture/workspace.json`. Commit
that file with intentional layout changes.
````

- [ ] **Step 2: Re-run workspace and Compose validation**

Run:

```bash
docker run --rm -v "$PWD:/workspace:ro" structurizr/structurizr@sha256:251905a1a2d73195e84b784966babc71b329223fdbb25368261a9e3ba39041c4 validate -workspace /workspace/architecture/workspace.dsl
docker compose -f architecture/compose.yaml config --quiet
```

Expected: both commands exit with code `0`.