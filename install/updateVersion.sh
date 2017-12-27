#!/bin/bash

# Copyright 2017 Istio Authors
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
VERSION_FILE="istio.VERSION"
SRC_VERSION_FILE="${ROOT}/${VERSION_FILE}"
TEMP_DIR="/tmp"
DEST_DIR=$ROOT
GIT_COMMIT=false
CHECK_GIT_STATUS=false

set -o errexit
set -o pipefail
set -x

function usage() {
  [[ -n "${1}" ]] && echo "${1}"

  cat <<EOF
usage: ${BASH_SOURCE[0]} [options ...]"
  options:
    -i ... URL to download istioctl binary
    -p ... <hub>,<tag> for the pilot docker image
    -x ... <hub>,<tag> for the mixer docker image
    -c ... <hub>,<tag> for the istio-ca docker image
    -a ... <hub>,<tag> Specifies same hub and tag for pilot, mixer, proxy, and istio-ca containers
    -r ... tag for proxy debian package
    -g ... create a git commit for the changes
    -n ... <namespace> namespace in which to install Istio control plane components
    -s ... check if template files have been updated with this tool
    -A ... URL to download auth debian packages
    -P ... URL to download pilot debian packages
    -E ... URL to download proxy debian packages
    -d ... directory to store file (optional, defaults to source code tree)
EOF
  exit 2
}

source "$SRC_VERSION_FILE" || error_exit "Could not source versions"

while getopts :gi:n:p:x:c:a:r:sA:P:E:d: arg; do
  case ${arg} in
    i) ISTIOCTL_URL="${OPTARG}";;
    n) ISTIO_NAMESPACE="${OPTARG}";;
    p) PILOT_HUB_TAG="${OPTARG}";; # Format: "<hub>,<tag>"
    x) MIXER_HUB_TAG="${OPTARG}";; # Format: "<hub>,<tag>"
    c) CA_HUB_TAG="${OPTARG}";; # Format: "<hub>,<tag>"
    a) ALL_HUB_TAG="${OPTARG}";; # Format: "<hub>,<tag>"
    r) PROXY_TAG="${OPTARG}";;
    g) GIT_COMMIT=true;;
    s) CHECK_GIT_STATUS=true;;
    A) AUTH_DEBIAN_URL="${OPTARG}";;
    P) PILOT_DEBIAN_URL="${OPTARG}";;
    E) PROXY_DEBIAN_URL="${OPTARG}";;
    d) DEST_DIR="${OPTARG}";;
    *) usage;;
  esac
done

if [[ -n ${ALL_HUB_TAG} ]]; then
    PILOT_HUB="$(echo ${ALL_HUB_TAG}|cut -f1 -d,)"
    PILOT_TAG="$(echo ${ALL_HUB_TAG}|cut -f2 -d,)"
    PROXY_HUB="$(echo ${ALL_HUB_TAG}|cut -f1 -d,)"
    PROXY_TAG="$(echo ${ALL_HUB_TAG}|cut -f2 -d,)"
    MIXER_HUB="$(echo ${ALL_HUB_TAG}|cut -f1 -d,)"
    MIXER_TAG="$(echo ${ALL_HUB_TAG}|cut -f2 -d,)"
    CA_HUB="$(echo ${ALL_HUB_TAG}|cut -f1 -d,)"
    CA_TAG="$(echo ${ALL_HUB_TAG}|cut -f2 -d,)"
fi

if [[ -n ${PILOT_HUB_TAG} ]]; then
    PILOT_HUB="$(echo ${PILOT_HUB_TAG}|cut -f1 -d,)"
    PILOT_TAG="$(echo ${PILOT_HUB_TAG}|cut -f2 -d,)"
fi

if [[ -n ${MIXER_HUB_TAG} ]]; then
    MIXER_HUB="$(echo ${MIXER_HUB_TAG}|cut -f1 -d,)"
    MIXER_TAG="$(echo ${MIXER_HUB_TAG}|cut -f2 -d,)"
fi

if [[ -n ${CA_HUB_TAG} ]]; then
    CA_HUB="$(echo ${CA_HUB_TAG}|cut -f1 -d,)"
    CA_TAG="$(echo ${CA_HUB_TAG}|cut -f2 -d,)"
fi

function error_exit() {
  # ${BASH_SOURCE[1]} is the file name of the caller.
  echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${1:-Unknown Error.} (exit ${2:-1})" 1>&2
  exit ${2:-1}
}

function set_git() {
  if [[ ! -e "${HOME}/.gitconfig" ]]; then
    cat > "${HOME}/.gitconfig" << EOF
[user]
  name = istio-testing
  email = istio.testing@gmail.com
EOF
  fi
}


function create_commit() {
  set_git
  # If nothing to commit skip
  check_git_status && return

  echo 'Creating a commit'
  git commit -a -m "Updating istio version" \
    || error_exit 'Could not create a commit'

}

function check_git_status() {
  local git_files="$(git status -s)"
  [[ -z "${git_files}" ]] && return 0
  return 1
}

#
# In-place portable sed operation
# the sed -i operation is not defined by POSIX and hence is not portable
#
function execute_sed() {
  sed -e "${1}" $2 > $2.new
  mv -- $2.new $2
}

# Generated merge yaml files for easy installation
function merge_files() {
  SRC=$TEMP_DIR/templates
  DEST=$DEST_DIR/install/kubernetes

  # istio.yaml and istio-auth.yaml file contain cluster-wide installations
  ISTIO=$DEST/istio.yaml
  ISTIO_AUTH=$DEST/istio-auth.yaml
  ISTIO_ONE_NAMESPACE=$DEST/istio-one-namespace.yaml
  ISTIO_ONE_NAMESPACE_AUTH=$DEST/istio-one-namespace-auth.yaml
  ISTIO_INITIALIZER=$DEST/istio-initializer.yaml
  ISTIO_CA_PLUGIN_CERTS=$DEST/istio-ca-plugin-certs.yaml

  echo "# GENERATED FILE. Use with Kubernetes 1.7+" > $ISTIO
  echo "# TO UPDATE, modify files in install/kubernetes/templates and run install/updateVersion.sh" >> $ISTIO
  cat $SRC/istio-ns.yaml.tmpl >> $ISTIO
  cat $SRC/istio-rbac-beta.yaml.tmpl >> $ISTIO
  cat $SRC/istio-mixer.yaml.tmpl >> $ISTIO
  cat $SRC/istio-config.yaml.tmpl >> $ISTIO
  cat $SRC/istio-pilot.yaml.tmpl >> $ISTIO
  cat $SRC/istio-ingress.yaml.tmpl >> $ISTIO

  cp $ISTIO $ISTIO_ONE_NAMESPACE
  cat $SRC/istio-ca.yaml.tmpl >> $ISTIO

  cp $ISTIO $ISTIO_AUTH
  execute_sed "s/# authPolicy: MUTUAL_TLS/authPolicy: MUTUAL_TLS/" $ISTIO_AUTH
  execute_sed "s/# controlPlaneAuthPolicy: MUTUAL_TLS/controlPlaneAuthPolicy: MUTUAL_TLS/" $ISTIO_AUTH
  execute_sed "s/NONE #--controlPlaneAuthPolicy/MUTUAL_TLS/" $ISTIO_AUTH
  execute_sed "s/envoy_mixer.json/envoy_mixer_auth.json/" $ISTIO_AUTH
  execute_sed "s/envoy_pilot.json/envoy_pilot_auth.json/" $ISTIO_AUTH

  # restrict pilot controllers to a single namespace in the test file
  execute_sed "s|args: \[\"discovery\", \"-v\", \"2\"|args: \[\"discovery\", \"-v\", \"2\", \"-a\", \"${ISTIO_NAMESPACE}\"|" $ISTIO_ONE_NAMESPACE
  cat $SRC/istio-ca-one-namespace.yaml.tmpl >> $ISTIO_ONE_NAMESPACE

  cp $ISTIO_ONE_NAMESPACE $ISTIO_ONE_NAMESPACE_AUTH
  execute_sed "s/# authPolicy: MUTUAL_TLS/authPolicy: MUTUAL_TLS/" $ISTIO_ONE_NAMESPACE_AUTH
  execute_sed "s/# controlPlaneAuthPolicy: MUTUAL_TLS/controlPlaneAuthPolicy: MUTUAL_TLS/" $ISTIO_ONE_NAMESPACE_AUTH
  execute_sed "s/NONE #--controlPlaneAuthPolicy/MUTUAL_TLS/" $ISTIO_ONE_NAMESPACE_AUTH
  execute_sed "s/envoy_mixer.json/envoy_mixer_auth.json/" $ISTIO_ONE_NAMESPACE_AUTH
  execute_sed "s/envoy_pilot.json/envoy_pilot_auth.json/" $ISTIO_ONE_NAMESPACE_AUTH

  echo "# GENERATED FILE. Use with Kubernetes 1.7+" > $ISTIO_INITIALIZER
  echo "# TO UPDATE, modify files in install/kubernetes/templates and run install/updateVersion.sh" >> $ISTIO_INITIALIZER
  cat ${SRC}/istio-initializer.yaml.tmpl >> $ISTIO_INITIALIZER

  echo "# GENERATED FILE. Use with Kubernetes 1.7+" > $ISTIO_CA_PLUGIN_CERTS
  echo "# TO UPDATE, modify files in install/kubernetes/templates and run install/updateVersion.sh" >> $ISTIO_CA_PLUGIN_CERTS
  cat $SRC/istio-ca-plugin-certs.yaml.tmpl >> $ISTIO_CA_PLUGIN_CERTS
}

function update_version_file() {
  cat <<EOF > "${DEST_DIR}/${VERSION_FILE}"
# DO NOT EDIT THIS FILE MANUALLY instead use
# install/updateVersion.sh (see install/README.md)
export CA_HUB="${CA_HUB}"
export CA_TAG="${CA_TAG}"
export MIXER_HUB="${MIXER_HUB}"
export MIXER_TAG="${MIXER_TAG}"
export PILOT_HUB="${PILOT_HUB}"
export PILOT_TAG="${PILOT_TAG}"
export ISTIOCTL_URL="${ISTIOCTL_URL}"
export PROXY_TAG="${PROXY_TAG}"
export ISTIO_NAMESPACE="${ISTIO_NAMESPACE}"
export AUTH_DEBIAN_URL="${AUTH_DEBIAN_URL}"
export PILOT_DEBIAN_URL="${PILOT_DEBIAN_URL}"
export PROXY_DEBIAN_URL="${PROXY_DEBIAN_URL}"
export FORTIO_HUB="${FORTIO_HUB}"
export FORTIO_TAG="${FORTIO_TAG}"
EOF
}

#
# Updating helm's values.yaml for the current versions
#
function update_helm_version() {
   helm_values_file="$ROOT/install/kubernetes/helm/istio/values.yaml"
   execute_sed "s|\(ca_hub: \).*|\1'${CA_HUB}'|g" $helm_values_file
   execute_sed "s|\(ca_tag: \).*|\1'${CA_TAG}'|g" $helm_values_file
   execute_sed "s|\(proxy_hub: \).*|\1'${PILOT_HUB}'|g" $helm_values_file
   execute_sed "s|\(proxy_tag: \).*|\1'${PROXY_TAG}'|g" $helm_values_file
   execute_sed "s|\(pilot_hub: \).*|\1'${PILOT_HUB}'|g" $helm_values_file
   execute_sed "s|\(pilot_tag: \).*|\1'${PILOT_TAG}'|g" $helm_values_file
   execute_sed "s|\(mixer_hub: \).*|\1'${MIXER_HUB}'|g" $helm_values_file
   execute_sed "s|\(mixer_tag: \).*|\1'${MIXER_TAG}'|g" $helm_values_file
}

function update_istio_install() {
  pushd $TEMP_DIR/templates
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-ns.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-rbac-beta.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-config.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-pilot.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-ingress.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-mixer.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-ca.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-ca-one-namespace.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-ca-plugin-certs.yaml.tmpl
  execute_sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" istio-initializer.yaml.tmpl

  execute_sed "s|image: {PILOT_HUB}/\(.*\):{PILOT_TAG}|image: ${PILOT_HUB}/\1:${PILOT_TAG}|" istio-pilot.yaml.tmpl
  execute_sed "s|image: {PROXY_HUB}/\(.*\):{PROXY_TAG}|image: ${PILOT_HUB}/\1:${PILOT_TAG}|" istio-pilot.yaml.tmpl
  execute_sed "s|image: {MIXER_HUB}/\(.*\):{MIXER_TAG}|image: ${MIXER_HUB}/\1:${MIXER_TAG}|" istio-mixer.yaml.tmpl
  execute_sed "s|image: {PROXY_HUB}/\(.*\):{PROXY_TAG}|image: ${PILOT_HUB}/\1:${PILOT_TAG}|" istio-mixer.yaml.tmpl
  execute_sed "s|image: {CA_HUB}/\(.*\):{CA_TAG}|image: ${CA_HUB}/\1:${CA_TAG}|" istio-ca.yaml.tmpl
  execute_sed "s|image: {CA_HUB}/\(.*\):{CA_TAG}|image: ${CA_HUB}/\1:${CA_TAG}|" istio-ca-one-namespace.yaml.tmpl
  execute_sed "s|image: {CA_HUB}/\(.*\):{CA_TAG}|image: ${CA_HUB}/\1:${CA_TAG}|" istio-ca-plugin-certs.yaml.tmpl

  execute_sed "s|{PILOT_HUB}|${PILOT_HUB}|" istio-initializer.yaml.tmpl
  execute_sed "s|{PILOT_TAG}|${PILOT_TAG}|" istio-initializer.yaml.tmpl

  execute_sed "s|image: {PROXY_HUB}/\(.*\):{PROXY_TAG}|image: ${PILOT_HUB}/\1:${PILOT_TAG}|" istio-ingress.yaml.tmpl

  popd
}

function update_istio_addons() {
  DEST=$DEST_DIR/install/kubernetes/addons
  mkdir -p $DEST
  pushd $TEMP_DIR/templates/addons
  execute_sed "s|image: {MIXER_HUB}/\(.*\):{MIXER_TAG}|image: ${MIXER_HUB}/\1:${MIXER_TAG}|" grafana.yaml.tmpl
  execute_sed "s|image: {MIXER_HUB}/\(.*\):{MIXER_TAG}|image: ${MIXER_HUB}/\1:${MIXER_TAG}|" servicegraph.yaml.tmpl
  sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" grafana.yaml.tmpl  > $DEST/grafana.yaml
  sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" prometheus.yaml.tmpl > $DEST/prometheus.yaml
  sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" servicegraph.yaml.tmpl > $DEST/servicegraph.yaml
  sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" zipkin.yaml.tmpl > $DEST/zipkin.yaml
  sed "s|{ISTIO_NAMESPACE}|${ISTIO_NAMESPACE}|" zipkin-to-stackdriver.yaml.tmpl > $DEST/zipkin-to-stackdriver.yaml
  popd
}

function update_istio_install_docker() {
  pushd $TEMP_DIR/templates
  execute_sed "s|image: {PILOT_HUB}/\(.*\):{PILOT_TAG}|image: ${PILOT_HUB}/\1:${PILOT_TAG}|" istio.yaml.tmpl
  execute_sed "s|image: {PILOT_HUB}/\(.*\):{PILOT_TAG}|image: ${PILOT_HUB}/\1:${PILOT_TAG}|" bookinfo.sidecars.yaml.tmpl
  execute_sed "s|image: {PILOT_HUB}/\(.*\):{PROXY_TAG}|image: ${PILOT_HUB}/\1:${PROXY_TAG}|" bookinfo.sidecars.yaml.tmpl
  popd
}

# Generated merge yaml files for easy installation
function merge_files_docker() {
  TYPE=$1
  SRC=$TEMP_DIR/templates

  # Merge istio.yaml install file
  INSTALL_DEST=$DEST_DIR/install/$TYPE
  ISTIO=${INSTALL_DEST}/istio.yaml

  mkdir -p $INSTALL_DEST
  echo "# GENERATED FILE. Use with Docker-Compose and ${TYPE}" > $ISTIO
  echo "# TO UPDATE, modify files in install/${TYPE}/templates and run install/updateVersion.sh" >> $ISTIO
  cat $SRC/istio.yaml.tmpl >> $ISTIO

  # Merge bookinfo.sidecars.yaml sample file
  SAMPLES_DEST=$DEST_DIR/samples/bookinfo/$TYPE
  BOOKINFO=${SAMPLES_DEST}/bookinfo.sidecars.yaml

  mkdir -p $SAMPLES_DEST
  echo "# GENERATED FILE. Use with Docker-Compose and ${TYPE}" > $BOOKINFO
  echo "# TO UPDATE, modify files in samples/bookinfo/${TYPE}/templates and run install/updateVersion.sh" >> $BOOKINFO
  cat $SRC/bookinfo.sidecars.yaml.tmpl >> $BOOKINFO
}

if [[ ${GIT_COMMIT} == true ]]; then
    check_git_status \
      || error_exit "You have modified files. Please commit or reset your workspace."
fi

mkdir -p $TEMP_DIR/templates
cp -R $ROOT/install/kubernetes/templates/* $TEMP_DIR/templates/
update_version_file
update_helm_version
update_istio_install
update_istio_addons
merge_files
rm -R $TEMP_DIR/templates

for platform in consul eureka
do
    cp -R $ROOT/install/$platform/templates $TEMP_DIR/templates
    cp -a $ROOT/samples/bookinfo/$platform/templates/. $TEMP_DIR/templates/
    update_istio_install_docker
    merge_files_docker $platform
    rm -R $TEMP_DIR/templates
done

if [[ ${GIT_COMMIT} == true ]]; then
    create_commit
fi

if [[ ${CHECK_GIT_STATUS} == true ]]; then
 check_git_status \
   || { echo "Need to update template and run install/updateVersion.sh"; git diff; exit 1; }
fi
