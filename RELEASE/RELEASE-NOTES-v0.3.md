---
release: "0.3"
date: 2026-06-03
type: minor
components:
  hyperfleet-api: { version: v0.3.0, image: "quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet/hyperfleet-api:0.3.0", digest: "sha256:24f8e7e3596d67048ef623232465a203717a64aacbaa08e83abba397465d2f6c" }
  hyperfleet-sentinel: { version: v0.3.0, image: "quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet/hyperfleet-sentinel:0.3.0", digest: "sha256:8d7a6fdab666892472bc5a622bf1c6ae3bf887f46c85201a0cfe3e6e19f11dc0" }
  hyperfleet-adapter: { version: v0.3.0, image: "quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet/hyperfleet-adapter:0.3.0", digest: "sha256:e48da38db70628746508121beb56370e82f12d0ba108cb3b5b002c296be1bfb3" }
---

# HyperFleet Release 0.3 — Release Notes

**Version:** v0.3.0
**Release Date:** June 3, 2026
**Type:** minor

> **IMPORTANT**: This MVP release is for exploration and evaluation only. Do not use in production environments.

## Overview

HyperFleet 0.3 delivers full cluster and nodepool lifecycle management — soft-delete, hard-delete, and force-delete with cascade logic — closing the gap from the create-only v0.2 API. A new generic ResourceService introduces plugin-based resource registration with descriptor-driven delete policies, laying the foundation for extensible resource types beyond clusters and nodepools. Observability is strengthened across all components with OpenTelemetry Helm chart configuration, production-ready JSON logging defaults, and new deletion metrics. This release also resolves CVE-2026-33186 (gRPC-Go authorization bypass) across all components.

## Highlights

- **Full deletion lifecycle** — soft-delete, hard-delete, and force-delete endpoints for clusters and nodepools with cascade logic, deletion metrics, and adapter-side resource cleanup
- **PATCH operations** — partial updates for clusters and nodepools via the API
- **Generic ResourceService** — plugin registration, descriptor-driven delete policies, and generic CRUD operations enabling extensible resource types
- **Reconciled status model** — Reconciled status aggregation replaces the Ready condition, providing clearer lifecycle semantics
- **OpenTelemetry improvements** — signal-specific OTLP env vars in Helm charts, span exporter for Adapter traces, and configurable tracing defaults
- **CVE-2026-33186 remediation** — gRPC-Go updated to v1.79.3 across all components to fix authorization bypass via missing leading slash in `:path`

## Component Versions

| Component | Version | Container Image | SHA256 Digest |
|-----------|---------|-----------------|---------------|
| **HyperFleet API** | v0.3.0 | `quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet/hyperfleet-api:0.3.0` | `sha256:24f8e7e3596d67048ef623232465a203717a64aacbaa08e83abba397465d2f6c` |
| **HyperFleet Sentinel** | v0.3.0 | `quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet/hyperfleet-sentinel:0.3.0` | `sha256:8d7a6fdab666892472bc5a622bf1c6ae3bf887f46c85201a0cfe3e6e19f11dc0` |
| **HyperFleet Adapter** | v0.3.0 | `quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet/hyperfleet-adapter:0.3.0` | `sha256:e48da38db70628746508121beb56370e82f12d0ba108cb3b5b002c296be1bfb3` |

## Security

- **CVE-2026-33186**: gRPC-Go authorization bypass via missing leading slash in `:path` — updated gRPC to v1.79.3 (API, Sentinel, Adapter) — [HYPERFLEET-762](https://redhat.atlassian.net/browse/HYPERFLEET-762), [HYPERFLEET-846](https://redhat.atlassian.net/browse/HYPERFLEET-846)

## Features

- Implement Cluster and NodePool DELETE handlers with cascade logic (API) [HYPERFLEET-543](https://redhat.atlassian.net/browse/HYPERFLEET-543)
- Add PATCH operations to OpenAPI spec for Cluster and NodePool (API) [HYPERFLEET-545](https://redhat.atlassian.net/browse/HYPERFLEET-545)
- Change Sentinel to use new configuration standard (Sentinel) [HYPERFLEET-549](https://redhat.atlassian.net/browse/HYPERFLEET-549)
- Review and validate resource limits (Sentinel) [HYPERFLEET-556](https://redhat.atlassian.net/browse/HYPERFLEET-556)
- Add CEL ext.Strings() to adapter framework (Sentinel, Adapter) [GCP-676](https://redhat.atlassian.net/browse/GCP-676)
- Provide RFC4122 UUID v7 identifier on Cluster and NodePool resources (API, Sentinel) [HYPERFLEET-732](https://redhat.atlassian.net/browse/HYPERFLEET-732)
- Expose BrokerType() on Publisher interface and remove MessagingSystem duplication (Sentinel) [HYPERFLEET-767](https://redhat.atlassian.net/browse/HYPERFLEET-767)
- Add OpenTelemetry span exporter to make traces visible (Adapter) [HYPERFLEET-789](https://redhat.atlassian.net/browse/HYPERFLEET-789)
- Implement deletion mode in resources phase executor (Adapter) [HYPERFLEET-849](https://redhat.atlassian.net/browse/HYPERFLEET-849)
- Add adapter deletion metrics and observability (Adapter) [HYPERFLEET-852](https://redhat.atlassian.net/browse/HYPERFLEET-852)
- Implement Reconciled status aggregation replacing Ready (API) [HYPERFLEET-853](https://redhat.atlassian.net/browse/HYPERFLEET-853)
- Implement hard-delete mechanism (API) [HYPERFLEET-854](https://redhat.atlassian.net/browse/HYPERFLEET-854)
- Add deletion observability metrics and alerts (API) [HYPERFLEET-856](https://redhat.atlassian.net/browse/HYPERFLEET-856)
- Support Go template lists in ManifestWork resources (Adapter) [HYPERFLEET-864](https://redhat.atlassian.net/browse/HYPERFLEET-864)
- Avoid running post actions when adapter does no work; add conditional escape (Adapter) [HYPERFLEET-876](https://redhat.atlassian.net/browse/HYPERFLEET-876)
- Standardize default log format to JSON across HyperFleet components (Sentinel) [HYPERFLEET-908](https://redhat.atlassian.net/browse/HYPERFLEET-908)
- Replace hardcoded PgBouncer sidecar with generic sidecar injection in Helm chart (API) [HYPERFLEET-937](https://redhat.atlassian.net/browse/HYPERFLEET-937)
- Reject nodepool create/update on soft-deleted cluster with 409 Conflict (API) [HYPERFLEET-971](https://redhat.atlassian.net/browse/HYPERFLEET-971)
- Change adapter status endpoints from POST to PUT to match upsert semantics (API) [HYPERFLEET-978](https://redhat.atlassian.net/browse/HYPERFLEET-978)
- Add OpenTelemetry environment variable configuration to Helm charts (API, Sentinel, Adapter) [HYPERFLEET-986](https://redhat.atlassian.net/browse/HYPERFLEET-986)
- Fix cascade nodepool delete leaving Ready condition stale (API) [HYPERFLEET-994](https://redhat.atlassian.net/browse/HYPERFLEET-994)
- Fix Helm chart rendering message_decision params in non-deterministic order (Sentinel) [HYPERFLEET-1011](https://redhat.atlassian.net/browse/HYPERFLEET-1011)
- Rename chart example resources to avoid name collisions on simultaneous deploy (Adapter) [HYPERFLEET-1012](https://redhat.atlassian.net/browse/HYPERFLEET-1012)
- Consume OpenAPI schemas from hyperfleet-api-spec Go module (API) [HYPERFLEET-1033](https://redhat.atlassian.net/browse/HYPERFLEET-1033)
- Force-delete nodepool endpoint (API) [HYPERFLEET-1041](https://redhat.atlassian.net/browse/HYPERFLEET-1041)
- Handle 404 gracefully on force-deleted resources (Adapter) [HYPERFLEET-1042](https://redhat.atlassian.net/browse/HYPERFLEET-1042)
- Remove Ready implementation (API) [HYPERFLEET-1052](https://redhat.atlassian.net/browse/HYPERFLEET-1052)
- Force-delete cluster endpoint (API) [HYPERFLEET-1081](https://redhat.atlassian.net/browse/HYPERFLEET-1081)
- Partner schema validation with fail-fast (API) [HYPERFLEET-1082](https://redhat.atlassian.net/browse/HYPERFLEET-1082)
- Resource data layer: type, DAO, migration, and entity registry (API) [HYPERFLEET-1084](https://redhat.atlassian.net/browse/HYPERFLEET-1084)
- ResourceService: generic CRUD operations (API) [HYPERFLEET-1085](https://redhat.atlassian.net/browse/HYPERFLEET-1085)
- Channel handler and plugin registration (API) [HYPERFLEET-1086](https://redhat.atlassian.net/browse/HYPERFLEET-1086)
- ResourceService: descriptor-driven delete policies (API) [HYPERFLEET-1093](https://redhat.atlassian.net/browse/HYPERFLEET-1093)
- Enable RabbitMQ as a configurable broker type for adapter Helm chart and E2E deployment (Adapter) [HYPERFLEET-1104](https://redhat.atlassian.net/browse/HYPERFLEET-1104)
- Disable tracing by default (API, Sentinel, Adapter) [HYPERFLEET-1114](https://redhat.atlassian.net/browse/HYPERFLEET-1114)
- Implement configurable caller identity resolution for audit fields (API) [HYPERFLEET-1134](https://redhat.atlassian.net/browse/HYPERFLEET-1134)

## Bug Fixes

- Return HTTP 503 instead of HTTP 500 when PostgreSQL is unavailable (API) [HYPERFLEET-659](https://redhat.atlassian.net/browse/HYPERFLEET-659)
- Optimize read-only requests to avoid unnecessary write transactions (API) [HYPERFLEET-724](https://redhat.atlassian.net/browse/HYPERFLEET-724)
- Remove deprecated sampling_rate field (API) [HYPERFLEET-762](https://redhat.atlassian.net/browse/HYPERFLEET-762)
- Fix pagination default pageSize mismatch between OpenAPI spec and code implementation (API) [HYPERFLEET-841](https://redhat.atlassian.net/browse/HYPERFLEET-841)
- Prevent advisory lock race condition with transactions (API) [HYPERFLEET-875](https://redhat.atlassian.net/browse/HYPERFLEET-875)
- Use semantic JSON comparison instead of bytes.Equal (API) [HYPERFLEET-995](https://redhat.atlassian.net/browse/HYPERFLEET-995)
- Disable JWT auth in default chart values (API) [HYPERFLEET-1039](https://redhat.atlassian.net/browse/HYPERFLEET-1039)
- Fix ClusterRole naming conflict in adapter chart to support concurrent installations (Adapter) [HYPERFLEET-1040](https://redhat.atlassian.net/browse/HYPERFLEET-1040)
- Fix vendor label in Dockerfiles for EC compliance (API, Sentinel, Adapter) [HYPERFLEET-1097](https://redhat.atlassian.net/browse/HYPERFLEET-1097)
- Make production the default runtime environment (API) [HYPERFLEET-1133](https://redhat.atlassian.net/browse/HYPERFLEET-1133)

## Known Issues

> **Note**: These are open bugs on HyperFleet components — candidates for human triage. Not every open bug is necessarily a release known issue.

- `status.conditions` serializes as `null` instead of empty array when resource has no conditions ([HYPERFLEET-1172](https://redhat.atlassian.net/browse/HYPERFLEET-1172))
- `fields` query parameter filter ignored on individual resource GET endpoints ([HYPERFLEET-1142](https://redhat.atlassian.net/browse/HYPERFLEET-1142))

## Upgrade Notes

_(To be completed — document any breaking changes, migration steps, or configuration changes required when upgrading from v0.2.1.)_

Key areas to verify:
- The **Ready condition has been replaced by Reconciled** — clients relying on `Ready` status must update to `Reconciled`
- **UUID v7** identifiers replace previous ID format — confirm downstream consumers handle the new format
- **Default log format changed to JSON** — update log parsers if consuming text-format logs
- **Adapter status endpoints changed from POST to PUT** — update any direct API callers
- **Tracing is now disabled by default** — set OTEL env vars explicitly if tracing is required

## Support

- **Issues**: JIRA HYPERFLEET project or component repositories
- **Community**: #forum-hyperfleet
