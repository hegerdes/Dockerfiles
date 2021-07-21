#!/bin/bash

IMAGE_NAME="hegerdes/vscode-latex"
VARIANTS=(debian:buster-slim debian:bullseye-slim ubuntu:focal ubuntu:bionic)
LANGUAGES=(all arabic chinese cjk cyrillic czechslovak english european french german greek italian japanese korean other polish portuguese spanish)
PUSH="FALSE"

#Set CWD
cd "$(dirname "$0")"
if [ $# -eq 1 ] && [ $1 = "push" ]; then
    echo "Will build and push to dockerhub"
    PUSH="TRUE"
fi

# Build base
for VARIANT in ${VARIANTS[@]}; do
    VARIANT_BUILD_TAG=(${VARIANT//:/ })
    VARIANT_NAME_TAG=(${VARIANT_BUILD_TAG[1]//-/ })
    echo "Building ${IMAGE_NAME}:${VARIANT_NAME_TAG[0]}..."
    docker build --build-arg VARIANT=$VARIANT -f "Dockerfile.base" -t $IMAGE_NAME:${VARIANT_NAME_TAG[0]} .
    if [ $PUSH = "TRUE" ]; then
        docker push $IMAGE_NAME:${VARIANT_NAME_TAG[0]}
    fi
done

# Build/tag latest
docker image tag $IMAGE_NAME:buster $IMAGE_NAME:latest
if [ $PUSH = "TRUE" ]; then
    docker push $IMAGE_NAME:latest
fi

# Build slim
for VARIANT in ${VARIANTS[@]}; do
    VARIANT_BUILD_TAG=(${VARIANT//:/ })
    VARIANT_NAME_TAG=(${VARIANT_BUILD_TAG[1]//-/ })
    echo "Building ${IMAGE_NAME}:${VARIANT_NAME_TAG[0]}-slim..."
    docker build --build-arg VARIANT=$VARIANT -f "Dockerfile.base-slim" -t $IMAGE_NAME:${VARIANT_NAME_TAG[0]}-slim .
    if [ $PUSH = "TRUE" ]; then
        docker push $IMAGE_NAME:${VARIANT_NAME_TAG[0]}-slim
    fi
done

# Build full
VARIANTS=(buster focal)
for VARIANT in ${VARIANTS[@]}; do
    echo "Building ${IMAGE_NAME}:${VARIANT}-full..."
    docker build --build-arg VARIANT=$VARIANT -f "Dockerfile.full" -t $IMAGE_NAME:${VARIANT}-full .
    if [ $PUSH = "TRUE" ]; then
        docker push $IMAGE_NAME:$VARIANT-full
    fi
done

# Build language variants
for VARIANT in ${VARIANTS[@]}; do
    for LANG in ${LANGUAGES[@]}; do
        echo "Building ${IMAGE_NAME}:${VARIANT}-lang-${LANG}..."
        docker build --build-arg VARIANT=$VARIANT --build-arg LANG=$LANG -f "Dockerfile.language" -t $IMAGE_NAME:${VARIANT}-lang-$LANG .
        if [ $PUSH = "TRUE" ]; then
            docker push $IMAGE_NAME:$VARIANT-lang-$LANG
        fi
    done
done
