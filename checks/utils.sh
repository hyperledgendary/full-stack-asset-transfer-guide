#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

SUCCESS="✅"
WARN="⚠️ "

# tests if varname is defined in the env AND it's an existing directory
function must_declare() {
  local varname=$1

  if [[ ${!varname+x} ]]
  then
    printf "%s %-40s%s\n" $SUCCESS $varname ${!varname}
  else
    printf "%s %-40s\n" ${WARN} $varname
    EXIT=1
  fi
}