# *******************************************************************************
# Copyright (c) 2026 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Apache License Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0
#
# SPDX-License-Identifier: Apache-2.0
# *******************************************************************************

# This file is sourced for version variables only. It should not be executed directly.
# shellcheck shell=sh disable=SC2034

# Pinned versions of Python tools run via uvx (uv's tool runner).
# Sourced by run_tool.sh, install.sh, and test scripts.
# To add a new tool, add a python_<name>=<version> line below.

python_reuse=6.2.0
