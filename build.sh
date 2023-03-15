#!/bin/bash 

SCRIPT_ROOT=$(realpath $(dirname "$0"))
CONTAINER_NAME="pico-sdk-build"
APP_NAME="rp2040-i2c-interface"

DOCKER_RUN_FLAGS="-it"
DOCKER_BASH_FLAGS="--login"

setup_docker () {
    docker build -t ${CONTAINER_NAME} \
        --build-arg USER_ID=$(id -u ${USER}) \
        --build-arg GROUP_ID=$(id -g ${USER}) \
        .
}

#--------------------------------------------------------------------------------------------------
docker_shell () {

    docker run ${DOCKER_RUN_FLAGS} \
        --user $(id -u):$(id -g) \
        --mount type=bind,source="${SCRIPT_ROOT}/${APP_NAME}",target=/app\
        ${CONTAINER_NAME} \
        /bin/bash ${DOCKER_BASH_FLAGS}
}


build_app () {
    # Make sure we have an output directory available.
    mkdir -p ${SCRIPT_ROOT}/${APP_NAME}/build/
    
    # Run the build step mounting the source directory read-only, but mountint the output directory for the cmake build directory.
    docker run ${DOCKER_RUN_FLAGS} \
        --user $(id -u):$(id -g) \
        --mount type=bind,source="${SCRIPT_ROOT}/${APP_NAME}",target=/app\
        ${CONTAINER_NAME} \
        /bin/bash ${DOCKER_BASH_FLAGS} -c "cd /app/ && make $@"
}

COMMAND=$1
shift

case $COMMAND in
    setup ) setup_docker ;;
    shell ) docker_shell ;;
    build ) build_app "$@" ;;
    # build_upload ) build_upload "$@" ;;
    # build_mock ) build_mock "$@" ;;
    # run ) run "$@" ;;
    # run_mock ) run_mock "$@" ;;
    # run_tests ) run_tests "$@" ;;
    # * ) print_help ;;
esac
