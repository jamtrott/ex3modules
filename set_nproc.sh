#!/usr/bin/env bash
# determine number of logical CPUs
if command -v nproc >/dev/null 2>&1; then
    NPROC=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
    NPROC=$(sysctl -n hw.ncpu)
else
    echo "Failed to detect number of logical CPUs"
    NPROC=1
fi
