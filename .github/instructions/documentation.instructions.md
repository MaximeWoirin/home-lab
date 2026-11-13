---
description: "Use when creating or editing deployed infrastructure documentation under docs."
applyTo: 'docs/**/*.md'
---

# Documentation Page Instructions

## Scope

These instructions apply to documentation pages under `docs/`. Keep pages factual, concise, and focused on infrastructure that exists and can be verified.

## Required Frontmatter

Every documentation page must start with YAML frontmatter containing:

```yaml
---
title: Descriptive page title
description: One-sentence description of the page
---
```

Because `title` provides the document title, begin the Markdown body with an H2 heading rather than an H1 heading.

## Standard Page Template

Use this structure for topic pages:

```markdown
---
title: Descriptive page title
description: One-sentence description of the page
---

## Scope

State what the page owns and what it deliberately leaves to another page.

## Current State

Record verified facts about deployed infrastructure.

## Boundaries and Dependencies

Describe ownership, interfaces, and dependencies with other deployed systems.

## Open Questions

List missing facts that must be verified before configuration or automation changes.
```

Directory index pages may use `Purpose`, `Reading Order`, and `Documentation Pattern` instead of the topic-page sections, but they must still use the required frontmatter and link to the topic pages they index.

## Section Guidance

### Scope

* Define the architectural or operational question answered by the page.
* Name the systems covered by the page.
* Link to another page when a detail belongs to a different ownership boundary.

### Current State

* Include only facts that are deployed and verified from configuration, inventory, or an observed system.
* Use canonical names, hostnames, IDs, addresses, versions, and units.
* Distinguish runtime state from configuration facts when both are relevant, such as `Deployed, running`.
* Mark unavailable facts as `Not documented` or move them to `Open Questions`.
* Do not infer a guest role, network placement, resource assignment, or dependency from an unlabeled artifact.

### Boundaries and Dependencies

* Identify which system owns each responsibility.
* Describe dependencies between deployed components, including network, storage, identity, and recovery dependencies.
* Keep implementation details in the owning configuration directory and link to them instead of duplicating them.

### Open Questions

* Ask only about missing facts of systems that exist.
* Phrase each item so it can be answered by an inventory command, configuration inspection, or explicit decision about the deployed environment.
* Do not use this section as a backlog or as a place to describe systems that do not exist.

## Factuality and Safety

* Do not document systems, capabilities, network segments, or service placements that do not exist and cannot be verified.
* Do not replace missing information with plausible values.
* Never include passwords, private keys, tokens, certificates, kubeconfigs, or unredacted device exports.
* Separate architectural explanation from executable configuration. The documentation should explain the deployed state without becoming a second source of configuration truth.

## Formatting and Links

* Use short paragraphs and one idea per bullet.
* Use tables for compact inventories and align table columns consistently.
* Use fenced code blocks with a language identifier for commands, configuration, and diagrams.
* Use Mermaid only when a deployed relationship is clearer as a diagram than as prose.
* Use relative links to repository files and keep links pointing to the canonical source.
* Keep headings in title case, surround them with blank lines, and end the file with one newline.

## Review Checklist

Before finalizing a documentation page, verify:

* Frontmatter contains `title` and `description`.
* The page has a clear scope and ownership boundary.
* Current-state claims are verified and use canonical identifiers.
* Dependencies refer only to deployed systems.
* Missing current facts are captured as open questions.
* No secrets or unredacted exports are present.
* Links resolve to existing repository files.
* The page follows the standard section order unless it is a directory index.