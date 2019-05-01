#!/usr/bin/env bash

SERVICE="sparkswap-lnd-engine"

ORG="crypdex"
VERSION="0.5.0-beta"
# IMAGE="golang:1.10-alpine"

# Get the location of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ENGINE_VERSION=$(node -pe "require('${DIR}/../package.json').version")

# Defaults
# LND_NODE=

TAG='v0.5.4-sparkswap-beta'

NETWORKS=(ltc btc)

ARCH="arm64v8 x86_64"

GOOS="linux"

for arch in ${ARCH}; do
  if [[ ${arch} = "arm64v8" ]]; then
    GOARCH="arm64"
    IMAGE="arm64v8/golang:1.11-stretch"
  elif [[ ${arch} = "x86_64" ]]; then
    GOARCH="amd64"
    IMAGE="golang:1.11-stretch"
  fi

  for network in ${NETWORKS[@]}; do
    green='\e[0;32m' # '\e[1;32m' is too bright for white bg.
    endColor='\e[0m'

    # Display welcome message
    echo -e "${green}Building Sparkswap LND Engine${endColor}"
    echo -e "${green}{arch: ${arch}, network: ${network}, image: ${IMAGE}, GOOS: ${GOOS}, GOARCH: ${GOARCH}}${endColor}"

    if [[ ${network} = 'ltc' ]]; then
      LND_NODE="litecoind"
    elif [[ ${network} = 'btc' ]]; then
      LND_NODE="bitcoind"
    fi

    tag=${ORG}/sparkswap-lnd-${network}:${ENGINE_VERSION}-${arch}

    docker -v build ./docker/lnd \
        -f ./docker/lnd/Dockerfile.multiarch \
        --build-arg IMAGE=${IMAGE} \
        --build-arg NODE=${LND_NODE} \
        --build-arg NETWORK=${network} \
        --build-arg GOOS=${GOOS} \
        --build-arg GOARCH=${GOARCH} \
        --build-arg TAG=${TAG} \
        -t ${tag}

    docker push ${tag}
  done

done


# Now create a manifest that points from latest to the specific architecture
rm -rf ~/.docker/manifests/*

for network in ${NETWORKS[@]}; do
  manifest="${ORG}/sparkswap-lnd-${network}:$ENGINE_VERSION"
  echo "=> Creating manifest for ${manifest}"

  docker manifest create ${manifest} ${manifest}-x86_64 ${manifest}-arm64v8
  docker manifest push ${manifest}
done


