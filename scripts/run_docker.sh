#!/bin/bash -e
#
# Run a local container build of ngspice-bin.
#
# Usage:
#   ./scripts/run_docker.sh [ngspice_version] [image]
#
# Examples:
#   ./scripts/run_docker.sh          # build latest (46) in manylinux_2_28_x86_64
#   ./scripts/run_docker.sh 46
#   ./scripts/run_docker.sh 46 manylinux_2_28_x86_64
#   ./scripts/run_docker.sh 46 manylinux2014_x86_64

ngspice_version=${1:-46}
image=${2:-manylinux_2_28_x86_64}

echo "Building ngspice ${ngspice_version} in ${image}..."

docker run --rm \
    --volume "$(pwd):/io" \
    --env ngspice_version="${ngspice_version}" \
    --env image="${image}" \
    --workdir /io \
    quay.io/pypa/${image} \
    /io/scripts/build.sh

echo "Done. Artifact in release/"
