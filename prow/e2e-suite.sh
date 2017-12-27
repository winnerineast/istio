#!/bin/bash

# Copyright 2017 Istio Authors

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


#######################################################
# e2e-suite triggered after istio/presubmit succeeded #
#######################################################

# Exit immediately for non zero status
set -e
# Check unset variables
set -u
# Print commands
set -x

if [ "${CI:-}" == 'bootstrap' ]; then
  export USER=Prow

  # Make sure we are in the right directory
  # Test harness will checkout code to directory $GOPATH/src/github.com/istio/istio
  # but we depend on being at path $GOPATH/src/istio.io/istio for imports
  if [[ ! $PWD = ${GOPATH}/src/istio.io/istio ]]; then
    # Test harness will checkout code to directory $GOPATH/src/github.com/istio/istio
    # but we depend on being at path $GOPATH/src/istio.io/istio for imports
    mv ${GOPATH}/src/github.com/istio ${GOPATH}/src/istio.io
    cd ${GOPATH}/src/istio.io/istio
  fi

  if [ -z "${PULL_PULL_SHA:-}" ]; then
    GIT_SHA="${PULL_BASE_SHA}"
  else
    GIT_SHA="${PULL_PULL_SHA}"
  fi

  # bootsrap upload all artifacts in _artifacts to the log bucket.
  ARTIFACTS_DIR=${ARTIFACTS_DIR:-"${GOPATH}/src/istio.io/istio/_artifacts"}
  E2E_ARGS+=(--test_logs_path="${ARTIFACTS_DIR}")
else
  # Use the current commit.
  GIT_SHA=${GIT_SHA:-"$(git rev-parse --verify HEAD)"}
fi

ISTIO_GO=$(cd $(dirname $0)/..; pwd)

HUB=${HUB:-"gcr.io/istio-testing"}

# Download envoy and go deps
${ISTIO_GO}/bin/init.sh

# Build istioctl, used by  the test.
make depend.ensure istioctl

echo 'Running Integration Tests'
./tests/e2e.sh ${E2E_ARGS[@]:-} "$@" \
  --mixer_tag "${GIT_SHA}"\
  --mixer_hub "${HUB}"\
  --pilot_tag "${GIT_SHA}"\
  --pilot_hub "${HUB}"\
  --ca_tag "${GIT_SHA}"\
  --ca_hub "${HUB}"\
  --istioctl ${GOPATH}/bin/istioctl
