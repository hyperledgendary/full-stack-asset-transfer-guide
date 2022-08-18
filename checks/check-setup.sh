#!/bin/bash

set -eou pipefail

# All checks run in the workshop root folder
cd "$(dirname "$0")"/..

. checks/utils.sh

EXIT=0

must_declare WORKSHOP_PATH
must_declare FABRIC_CFG_PATH

exit $EXIT

