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

# Print commands
set -x

# Local vars
ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
ARGS=(-alsologtostderr -test.v -v 2)
TESTSPATH='tests/e2e/tests'

function print_block() {
    line='--------------------------------------------------'

    echo $line
    echo $1
    echo $line
}

function error_exit() {
    # ${BASH_SOURCE[1]} is the file name of the caller.
    echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${1:-Unknown Error.} (exit ${2:-1})" 1>&2
    exit ${2:-1}
}

TESTS_TARGETS="./tests/e2e/tests/simple ./tests/e2e/tests/mixer ./tests/e2e/tests/bookinfo"
TOTAL_FAILURE=0
SUMMARY='Tests Summary'

SINGLE_MODE=false

function process_result() {
    if [[ $1 -eq 0 ]]; then
        SUMMARY+="\nPASSED: $2 "
    else
        SUMMARY+="\nFAILED: $2 "
        ((FAILURE_COUNT++))
    fi
}

function sequential_exec() {
    for T in ${TESTS_TARGETS[@]}; do
        single_exec ${T}
    done
}

function single_exec() {
    print_block "Running $1"
    # Bookinfo is very slow, waiting for cleanup and sync.
    go test -timeout 20m ${TEST_ARGS:-} $1 -args ${ARGS[@]}
    #bazel ${BAZEL_STARTUP_ARGS} run ${BAZEL_RUN_ARGS} $1 -- ${ARGS[@]}
    process_result $? $1
}

# getopts only handles single character flags
for ((i=1; i<=$#; i++)); do
    case ${!i} in
        # -s/--single_test to specify only one test to run.
        # e.g. "-s mixer" will only trigger mixer:go_default_test
        -s|--single_test) SINGLE_MODE=true; ((i++)); SINGLE_TEST=${!i}
        continue
        ;;
    esac
    # Filter -p out as it is not defined in the test framework
    ARGS+=( ${!i} )
done

if ${SINGLE_MODE}; then
    echo "Executing single test"
    SINGLE_TEST=./${TESTSPATH}/${SINGLE_TEST}

    # Check if it's a valid test file
    VALID_TEST=false
    for T in ${TESTS_TARGETS[@]}; do
        if [ "${T}" == "${SINGLE_TEST}" ]; then
            VALID_TEST=true
            single_exec ${SINGLE_TEST}
        fi
    done
    if [ "${VALID_TEST}" == "false" ]; then
      echo "Invalid test directory, type folder name under ${TESTSPATH} in istio/istio repo"
      # Fail if it's not a valid test file
      process_result 1 'Invalid test directory'
    fi

else
    echo "Executing tests sequentially"
    sequential_exec
fi

printf "${SUMMARY}\n"
exit ${FAILURE_COUNT}
