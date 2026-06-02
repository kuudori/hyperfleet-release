#!/usr/bin/env bash
#
# Trigger the Prow RC E2E job for the versions in RELEASE_MANIFEST.yaml via Gangway.
#
# This is the manual trigger used until the tag-driven GitHub Action is wired up
# (see scripts/README.md and HYPERFLEET-1038). It reads the manifest, optionally
# verifies the images exist in Quay, then POSTs to Gangway with the per-component
# image tags and the E2E_REF override.
#
# Requires an app.ci token in GANGWAY_TOKEN -- see scripts/README.md.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="${MANIFEST:-${SCRIPT_DIR}/../RELEASE_MANIFEST.yaml}"

GANGWAY_URL="https://gangway-ci.apps.ci.l2s4.p1.openshiftapps.com/v1/executions"
JOB_NAME="periodic-ci-openshift-hyperfleet-hyperfleet-e2e-main-rc-e2e-rc-e2e"
PROW_URL="https://prow.ci.openshift.org/?job=${JOB_NAME}"
REGISTRY="quay.io/redhat-services-prod/hyperfleet-tenant/hyperfleet"
NAMESPACE_PREFIX="${NAMESPACE_PREFIX:-rc-e2e}"
DRY_RUN="${DRY_RUN:-}"   # set to any value to print the payload and skip the Gangway call

for tool in yq jq curl; do
  command -v "${tool}" >/dev/null 2>&1 || { echo "ERROR: '${tool}' is required but not installed." >&2; exit 1; }
done

[ -f "${MANIFEST}" ] || { echo "ERROR: manifest not found: ${MANIFEST}" >&2; exit 1; }

if [ -z "${GANGWAY_TOKEN:-}" ] && [ -z "${DRY_RUN}" ]; then
  cat >&2 <<'EOF'
ERROR: GANGWAY_TOKEN is not set.

Get an app.ci token:
  1. Log into https://console-openshift-console.apps.ci.l2s4.p1.openshiftapps.com/
     (use the Red Hat SSO identity provider)
  2. Top-right (your name) -> Copy login command -> Display Token
  3. Run the 'oc login ...' command it shows, then:
       export GANGWAY_TOKEN=$(oc whoami -t)

Make sure the token is from app.ci, not the Konflux cluster, or Gangway returns 401.
See scripts/README.md for details.
EOF
  exit 1
fi

# Read the manifest (mikefarah yq v4). Strip the leading 'v' so tags match Quay.
api_tag="$(yq '.components.hyperfleet-api' "${MANIFEST}" | sed 's/^v//')"
sentinel_tag="$(yq '.components.hyperfleet-sentinel' "${MANIFEST}" | sed 's/^v//')"
adapter_tag="$(yq '.components.hyperfleet-adapter' "${MANIFEST}" | sed 's/^v//')"
e2e_ref="$(yq '.e2e_ref' "${MANIFEST}")"
[ "${e2e_ref}" = "null" ] && e2e_ref=""

echo "Manifest: ${MANIFEST}"
echo "  hyperfleet-api:      ${api_tag}"
echo "  hyperfleet-sentinel: ${sentinel_tag}"
echo "  hyperfleet-adapter:  ${adapter_tag}"
echo "  e2e_ref:             ${e2e_ref:-<default: test binary built from pod image / main>}"
echo "  namespace_prefix:    ${NAMESPACE_PREFIX}"
echo

# Optional pre-flight: confirm the images exist in Quay before triggering, so we
# don't waste a ~1h E2E run on a missing or mistyped tag. Uses podman if available
# (no layer pull, no auth needed -- the registry is public); skipped otherwise.
if command -v podman >/dev/null 2>&1; then
  echo "Verifying images in Quay (podman manifest inspect)..."
  missing=0
  for pair in \
    "hyperfleet-api:${api_tag}" \
    "hyperfleet-sentinel:${sentinel_tag}" \
    "hyperfleet-adapter:${adapter_tag}"; do
    comp="${pair%%:*}"
    tag="${pair##*:}"
    if podman manifest inspect "${REGISTRY}/${comp}:${tag}" >/dev/null 2>&1; then
      echo "  OK   ${comp}:${tag}"
    else
      echo "  MISS ${comp}:${tag}  (not found in ${REGISTRY})"
      missing=1
    fi
  done
  if [ "${missing}" -ne 0 ]; then
    echo "ERROR: one or more images are missing -- aborting. Did Konflux finish building and releasing?" >&2
    exit 1
  fi
else
  echo "podman not found -- skipping image verification (the Prow job will fail if an image is missing)."
fi
echo

# Build the Gangway payload. E2E_REF is only sent when set.
envs="$(jq -n \
  --arg api "${api_tag}" \
  --arg sentinel "${sentinel_tag}" \
  --arg adapter "${adapter_tag}" \
  --arg ns "${NAMESPACE_PREFIX}" \
  --arg e2e_ref "${e2e_ref}" \
  '{
     MULTISTAGE_PARAM_OVERRIDE_API_IMAGE_TAG: $api,
     MULTISTAGE_PARAM_OVERRIDE_SENTINEL_IMAGE_TAG: $sentinel,
     MULTISTAGE_PARAM_OVERRIDE_ADAPTER_IMAGE_TAG: $adapter,
     MULTISTAGE_PARAM_OVERRIDE_NAMESPACE_PREFIX: $ns
   }
   + (if $e2e_ref != "" then {MULTISTAGE_PARAM_OVERRIDE_E2E_REF: $e2e_ref} else {} end)')"

payload="$(jq -n --argjson envs "${envs}" '{job_execution_type: "1", pod_spec_options: {envs: $envs}}')"

if [ -n "${DRY_RUN}" ]; then
  echo "DRY_RUN set -- not triggering. Payload that would be POSTed to:"
  echo "  ${GANGWAY_URL}/${JOB_NAME}"
  printf '%s\n' "${payload}" | jq .
  exit 0
fi

echo "Triggering ${JOB_NAME}..."
response="$(curl -s -w $'\n%{http_code}' -X POST \
  -H "Authorization: Bearer ${GANGWAY_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${payload}" \
  "${GANGWAY_URL}/${JOB_NAME}")"

http_code="$(printf '%s' "${response}" | tail -n1)"
body="$(printf '%s' "${response}" | sed '$d')"

if [ "${http_code}" = "200" ]; then
  echo "Triggered successfully:"
  printf '%s\n' "${body}" | jq .
  echo
  echo "Watch: ${PROW_URL}"
  echo "(Gangway does not return a direct run URL -- open the link and pick the newest run.)"
else
  echo "ERROR: Gangway returned HTTP ${http_code}" >&2
  printf '%s\n' "${body}" >&2
  exit 1
fi
