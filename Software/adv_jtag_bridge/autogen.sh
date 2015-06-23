#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
set -o posix

set -x  # Trace the commands as they are executed.

autoreconf --warnings=all --install
