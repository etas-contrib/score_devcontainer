#!/usr/bin/env bash

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

# Unified entry point for running a CLI tool by name.
# Inside a container the tool is expected on PATH; outside, it is resolved via Bazel.
# See tools/README.md for the rationale behind supporting both paths.

set -euo pipefail

if [[ "$#" -lt 1 ]]; then
    echo "Usage: $0 <tool> [args...]" >&2
    exit 2
fi

tool_name="$1"
shift

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repository_root="$(cd "${script_dir}/.." && pwd -P)"

if { [[ -f /.dockerenv ]] || [[ -f /run/.containerenv ]] || [[ -d /devcontainer ]]; } &&
    command -v "${tool_name}" >/dev/null 2>&1; then
    exec "${tool_name}" "$@"
fi

# Python tools incl their dependencies are managed via uvx instead of
# rules_multitool. The whitelist and pinned versions live in python_tools.lock.sh.
# If the tool is listed there, uvx_version will be set to the pinned version.
. "${script_dir}/lockfiles/python_tools.lock.sh"
uvx_version_var="python_${tool_name}"
uvx_version="${!uvx_version_var:-}"
if [[ -n "${uvx_version}" ]]; then
    # Prefer a locally installed uvx; fall back to the Bazel-managed one.
    if command -v uvx >/dev/null 2>&1; then
        exec uvx "${tool_name}@${uvx_version}" "$@"
    elif command -v bazel >/dev/null 2>&1; then
        cd "${repository_root}"
        exec bazel run "//tools:uvx" -- "${tool_name}@${uvx_version}" "$@"
    fi
    echo "Could not run '${tool_name}': uvx-managed tool, but neither uvx nor bazel found." >&2
    exit 127
fi

if command -v bazel >/dev/null 2>&1; then
cd "${repository_root}"
exec bazel run "//tools:${tool_name}" -- "$@"
fi

echo "Could not run '${tool_name}': not available on PATH in a container, and bazel was not found." >&2
exit 127
