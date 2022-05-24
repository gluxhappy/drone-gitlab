#!/usr/bin/env bash

go_scm_version=v1.21.1
drone_server_version=v2.12.1

BASE_DIR=$(dirname "$0")
BASE_DIR=$(realpath "$BASE_DIR")
cd "$BASE_DIR"

go_docker_base="docker run --rm -it \
    -v $BASE_DIR:/src \
    -w /src/drone \
    -e GOARCH=amd64 \
    -e GOOS=linux"
if [ -d "${GOPATH}" ]; then
    go_docker_base="$go_docker_base -e GOPATH=/go -v $GOPATH:/go"
fi 
go_docker_base="$go_docker_base golang:1.14.15"


if [ -d "go-scm" ]; then
   echo "Found existing code base for go-scm"
else 
    git clone git@github.com:drone/go-scm.git || exit 1
    cd go-scm
    git fetch --tags || exit 1
    git checkout -b ${go_scm_version} ${go_scm_version} || exit 1
    git apply ../go-scm.patch || exit 1
fi

cd "$BASE_DIR"
if [ -d "drone" ]; then
   echo "Found existing code base for drone-server"
else
    git clone git@github.com:harness/drone.git || exit 1
    cd drone || exit 1
    git fetch --tags || exit 1
    git checkout -b ${drone_server_version} ${drone_server_version} || exit 1   
    git apply ../drone.patch || exit 1
    ${go_docker_base} go mod edit -replace=github.com/drone/go-scm=../go-scm
    # curl -L -o drone.zip https://github.com/harness/drone/archive/refs/tags/v2.12.0.zip
    # unzip drone.zip
fi

${go_docker_base} /usr/bin/env bash scripts/build.sh

cd drone

timestamp=$(date +%Y%m%d%H%M%S)
docker_image_version="${drone_server_version}_${timestamp}"
docker_image_tag="drone-server-gitlab:${docker_image_version}"
ls -al release/linux/amd64
docker build -t ${docker_image_tag} -f docker/Dockerfile.server.linux.amd64 .

# comment out if you want to push to dockerhub
exit 0
push_tag="gluxhappy/${docker_image_tag}"
docker tag ${docker_image_tag} ${push_tag}
docker push $push_tag
