#!/bin/bash

export DOCKER_VERSION=7.2.0

function build_docker() {
    # cp $(basename $0) docker/files -ardf
    # --build-arg HTTP_PROXY="http://localhost:20171" --build-arg HTTPS_PROXY="http://localhost:20171" --build-arg NO_PROXY=localhost,127.0.0.1
    docker build ./docker -t rti_dev:${DOCKER_VERSION}
}

function run_docker() {
    local docker_name=$(basename "$(pwd)")_job
    if [[ ! "$(docker ps -aqf "name=${docker_name}")" ]]; then
        info "Start New Docker Container"
        docker run -itd --privileged \
            --name=${docker_name} \
            --net=host \
            -v /dev/bus/usb:/dev/bus/usb \
            -v ${top_dir}:/rti \
            jetson_dev:${DOCKER_VERSION}
    fi

    if ! docker ps -qf "name=$docker_name" | grep -q .; then
        docker start ${docker_name}
    fi
    docker exec -it ${docker_name} fish
}

function usage() {
    local ScriptName=$1
    cat <<EOF
    Use: "${ScriptName}" 
        [ --build_docker ] Build Dev Docker Image
        [ --run_docker | -r ]  Run L4t Dev Docker
        [ --help | -h ] Print This Message
EOF
}

function parse_args() {
    while [ -n "${1}" ]; do
        case "${1}" in
        -h | --help)
            usage $(basename "$0")
            exit 0
            ;;
        --build_docker)
            build_docker
            exit 0
            ;;
        -r | --run_docker)
            run_docker
            exit 0
            ;;
        *)
            error "ERROR: Invalid parameter. Exiting..."
            usage
            exit 1
            ;;
        esac
    done
}

parse_args $@