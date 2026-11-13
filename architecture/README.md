---
title: Structurizr Architecture
description: Local workflow for viewing and validating the version-controlled Structurizr C4 model.
---

## Purpose

This directory owns the local, version-controlled Structurizr C4 model for the
deployed home lab. `workspace.dsl` is the canonical model and must represent
verified deployed facts only.

The model provides four views: system context, platform, network, and
deployment.

## Run Locally

From the repository root, start the local viewer:

```bash
docker compose -f architecture/compose.yaml up
```

Open <http://127.0.0.1:8080> in a browser. Stop the viewer with Ctrl+C or run:

```bash
docker compose -f architecture/compose.yaml down
```

## Validate

From the repository root, validate the canonical DSL:

```bash
docker run --rm -v "$PWD:/workspace:ro" structurizr/structurizr@sha256:251905a1a2d73195e84b784966babc71b329223fdbb25368261a9e3ba39041c4 validate -workspace /workspace/architecture/workspace.dsl
```

## Layout Changes

The local UI may generate `architecture/workspace.json` for manual layout.
Do not edit this generated local-state file by hand. It is ignored so that
`workspace.dsl` remains the shared source of truth.

## Local Boundary

The viewer is bound to localhost and is not deployed to the home lab.