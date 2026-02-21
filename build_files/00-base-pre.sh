#!/bin/bash

set -xeuo pipefail

dnf install -y epel-release && dnf update -y

dnf -y remove \
  console-login-helper-messages \
  chrony \
  sssd* \
  qemu-user-static* \
  toolbox
