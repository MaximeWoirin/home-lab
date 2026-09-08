---
title: Home Lab Agent Guidelines
description: Project-wide guidance for documenting and managing the home-lab infrastructure repository
---

## Purpose

* Treat this repository as the documentation and source of truth for the home lab.
* Keep infrastructure changes reproducible, reviewable, and recoverable.
* Cover infrastructure documentation, host configuration, initialization scripts, cluster building blocks, and firewall configuration for systems that exist and are verified.
* Document only deployed and verified infrastructure. Do not document components that do not exist and cannot be verified.

## Repository Boundaries

* Keep each configuration under the directory or module owned by the system it configures.
* Separate documentation, declarative infrastructure, cluster resources, system configuration, and operational scripts when those areas are added.
* Prefer one canonical source for each setting. Link to that source from documentation instead of maintaining competing copies.
* Treat generated files and exported device configuration as derived artifacts when a source representation exists. Do not edit derived output by hand.
* Preserve boundaries between virtualization, firewall, Kubernetes, and shared network concerns. Document dependencies when a change crosses those boundaries.

## Infrastructure Safety

* Never commit passwords, private keys, API tokens, certificates, recovery codes, or unredacted device exports.
* Do not invent credentials, network ranges, hostnames, routes, firewall rules, or service dependencies. Discover them from repository sources or ask when they are not documented.
* Mark examples and placeholders clearly. Keep real values in an approved secret-management workflow that is documented without exposing the secret.
* Require explicit user approval before firewall changes, routing changes, access-control changes, service restarts, destructive operations, or infrastructure apply commands.
* Before changing infrastructure, identify the affected system, dependencies, rollback or recovery path, and validation check.
* Preserve existing user changes in the working tree. Inspect the current state before editing and keep unrelated changes out of the diff.

## Working Workflow

1. Read the relevant documentation and configuration before changing it.
2. Identify the owning system and the narrowest file or module that controls the behavior.
3. Make the smallest change that satisfies the request.
4. Run the repository's documented formatter, linter, parser, test, or plan checks when they exist.
5. Inspect the final diff for unintended changes, leaked sensitive values, and mismatches between documentation and configuration.
6. Report validation performed, affected systems, assumptions, and any remaining manual steps.

No build, test, deployment, or validation commands are established yet. Do not claim that a command passed or invent a project command. Add commands to the repository documentation when tooling becomes available.

## Documentation

* Update the relevant documentation whenever an infrastructure change alters behavior, dependencies, access, recovery steps, or operational assumptions.
* Record enough context for recovery after a host, VM, container, cluster, or configuration loss.
* Keep documentation factual and limited to deployed state. Record missing details as open questions rather than assumptions about undocumented systems.
* Use precise names for systems and environments once they are defined, and link to detailed documents instead of duplicating them.
* Document validation and rollback procedures alongside operational configuration.

## Change Review

* Prefer idempotent automation and declarative configuration where the target system supports it.
* Review security and network exposure whenever a service becomes reachable from another trust boundary.
* Avoid broad refactors while changing infrastructure behavior.
* Do not apply changes to live infrastructure or create a commit unless the user explicitly requests that action.