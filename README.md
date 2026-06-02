# HyperFleet Release Repository

This repository contains official release documentation for the HyperFleet project.

### Components

| Component | Repository |
|-----------|------------|
| HyperFleet API | [openshift-hyperfleet/hyperfleet-api](https://github.com/openshift-hyperfleet/hyperfleet-api) |
| HyperFleet Sentinel | [openshift-hyperfleet/hyperfleet-sentinel](https://github.com/openshift-hyperfleet/hyperfleet-sentinel) |
| HyperFleet Adapter | [openshift-hyperfleet/hyperfleet-adapter](https://github.com/openshift-hyperfleet/hyperfleet-adapter) |

### RC E2E Testing

[`RELEASE_MANIFEST.yaml`](./RELEASE_MANIFEST.yaml) records the component image versions and test-suite ref that make up a release candidate. Use [`scripts/trigger-rc-e2e.sh`](./scripts/trigger-rc-e2e.sh) to run the RC E2E test job against those images — see [`scripts/README.md`](./scripts/README.md).

### Support

- **Issues**: JIRA HYPERFLEET project or component repositories
- **Community**: #forum-hyperfleet
