# RC E2E Testing (manual trigger)

This directory holds the manual trigger for the **release-candidate end-to-end (RC E2E)** test job, which tests Konflux-built RC images on Prow before a GA release.

> **Status:** manual trigger (interim). A tag-driven GitHub Action will replace the manual step once a Gangway service-account token is provisioned — see [HYPERFLEET-1038](https://redhat.atlassian.net/browse/HYPERFLEET-1038). The Action reuses this same script and manifest, so the flow below does not change.

## How it works

```
RELEASE_MANIFEST.yaml ──► trigger-rc-e2e.sh ──► Gangway API ──► Prow RC E2E job
  (versions + refs)        (verify in Quay)                     (tier0 + tier1 on GKE)
```

- [`RELEASE_MANIFEST.yaml`](../RELEASE_MANIFEST.yaml) (repo root) records the per-component image versions, chart refs, the `hyperfleet-infra` ref (`infra_ref`), and the `hyperfleet-e2e` branch (`e2e_ref`) that form a release candidate.
- `trigger-rc-e2e.sh` reads the manifest, verifies the listed images exist in Quay, and triggers the Prow job `periodic-ci-openshift-hyperfleet-hyperfleet-e2e-main-rc-e2e-rc-e2e` via Gangway, injecting the image tags, chart refs, `INFRA_REF` and `E2E_REF`. Chart refs and the infra ref are passed through the `MULTISTAGE_PARAM_OVERRIDE_*_CHART_REF` and `MULTISTAGE_PARAM_OVERRIDE_INFRA_REF` variables; if omitted, the Prow setup defaults them to `main`. If the manifest includes `hyperfleet-applier`, the script verifies its image and passes the Applier override to Prow. If an older manifest omits it, the script preserves compatibility with three-component releases.

## Prerequisites

- **Required CLI:** `yq` (mikefarah), `jq`, `curl`.
- **Optional CLI:** `podman` — used for the pre-flight "do the images exist in Quay?" check. If it isn't installed, the check is skipped and the job still triggers (it'll just fail later if an image is genuinely missing).
- **Optional CLI:** `git` — used for the pre-flight "do the refs exist?" check (`git ls-remote`, no clone). Skipped if `git` isn't installed.
- **app.ci access + token.** The job runs on OpenShift CI (`app.ci`), so you need a token from that cluster:
  1. Log into <https://console-openshift-console.apps.ci.l2s4.p1.openshiftapps.com/> (Red Hat SSO).
  2. Top-right (your name) → **Copy login command** → **Display Token**.
  3. Run the `oc login …` command it gives you, then:
     ```bash
     export GANGWAY_TOKEN=$(oc whoami -t)
     ```
  > Make sure the token is from **app.ci**, not the Konflux cluster — otherwise Gangway returns 401.

## Run it

1. Update [`RELEASE_MANIFEST.yaml`](../RELEASE_MANIFEST.yaml) with the RC versions and refs:
   ```yaml
   release: "0.3"
   e2e_ref: release-0.3
   infra_ref: release-0.3 # hyperfleet-infra branch or tag to deploy from
   chart_refs:
     hyperfleet-api: v0.3.0
     hyperfleet-sentinel: v0.3.0
     hyperfleet-adapter: v0.3.0
   components:
     hyperfleet-api: v0.3.0-rc1
     hyperfleet-sentinel: v0.3.0-rc1
     hyperfleet-adapter: v0.3.0-rc1
     hyperfleet-applier: v0.1.0-rc1 # include when applier is part of the release
   ```
2. Export your token (above) and run:
   ```bash
   ./scripts/trigger-rc-e2e.sh
   ```
3. Open the printed Prow link and select the newest run (Gangway doesn't return a direct URL).

**Retrigger** (e.g. after a flake): just run the script again — it re-reads the manifest.

**Dry run** (no token needed): `DRY_RUN=1 ./scripts/trigger-rc-e2e.sh` reads the manifest, verifies the images in Quay and the git refs, and prints the exact Gangway payload **without triggering anything** — handy for sanity-checking the manifest before a real run.

## What the job does

- Pulls the RC images listed in the manifest from `quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet/*`.
- When `e2e_ref` is set, clones `hyperfleet-e2e` at that branch, builds the test binary, and deploys with that branch's scripts.
- Clones `hyperfleet-infra` at `infra_ref` (default `main`) and deploys the API, Sentinel and Adapter charts at their `chart_refs` (default `main`).
- Deploys to the `hyperfleet-dev-prow` GKE cluster and runs `tier0 || tier1`.

## Notes

- The manifest — not Konflux — is the human-maintained record of *which combination* of images is under test. Konflux Snapshots remain the build source of truth.
- Image tags in Quay have no `v` prefix (the Konflux pipeline strips it); the script strips `v` from the manifest values to match.
