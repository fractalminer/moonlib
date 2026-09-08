#!/bin/bash
set -eo pipefail

this="$(dirname "$0")"
cd "$this"

make clean

bear -- make -j