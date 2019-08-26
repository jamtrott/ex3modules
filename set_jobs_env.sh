#!/usr/bin/env bash
# determine number of logical CPUs
if command -v nproc >/dev/null 2>&1; then
    JOBS=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
    JOBS=$(sysctl -n hw.ncpu)
else
    echo "Failed to detect number of logical CPUs"
    JOBS=1
fi
