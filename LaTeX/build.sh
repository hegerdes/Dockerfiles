#!/bin/bash

IMAGE_NAME="hegerdes/vscode-latex"
VARIANTS=(buster stretch focal bionic)
LANGUAGES=(all arabic chinese cjk cyrillic czechslovak english european french german greek italian japanese korean other polish portuguese spanish)
PUSH="FALSE"

#Set CWD
cd "$(dirname "$0")"
if [ $# -eq 1 ] && [ $1 = "push" ]; then
    echo "Will build and push to dockerhub"
    PUSH="TRUE"
fi

for VARIANT in ${VARIANTS[@]}; do
    echo "Building ${IMAGE_NAME}:${VARIANT}-base..."
    docker build --build-arg VARIANT=$VARIANT -f "Dockerfile.base" -t $IMAGE_NAME:$VARIANT-base .
    if [ $PUSH = "TRUE" ]; then
        docker push $IMAGE_NAME:$VARIANT-base
    fi
done

for VARIANT in ${VARIANTS[@]}; do
    echo "Building ${IMAGE_NAME}:${VARIANT}-base-slim..."
    docker build --build-arg VARIANT=$VARIANT -f "Dockerfile.base-slim" -t $IMAGE_NAME:$VARIANT-base-slim .
    if [ $PUSH = "TRUE" ]; then
        docker push $IMAGE_NAME:$VARIANT-base-slim
    fi
done

VARIANTS=(buster focal)
for VARIANT in ${VARIANTS[@]}; do
    echo "Building ${IMAGE_NAME}:${VARIANT}-full..."
    docker build --build-arg VARIANT=$VARIANT-base -f "Dockerfile.full" -t $IMAGE_NAME:$VARIANT-full .
    if [ $PUSH = "TRUE" ]; then
        docker push $IMAGE_NAME:$VARIANT-full
    fi
done

for VARIANT in ${VARIANTS[@]}; do
    for LANG in ${LANGUAGES[@]}; do
        echo "Building ${IMAGE_NAME}:${VARIANT}-lang-${LANG}..."
        docker build --build-arg VARIANT=$VARIANT-base --build-arg LANG=$LANG -f "Dockerfile.language" -t $IMAGE_NAME:$VARIANT-lang-$LANG .
        if [ $PUSH = "TRUE" ]; then
            docker push $IMAGE_NAME:$VARIANT-lang-$LANG
        fi
    done
done

docker image tag $IMAGE_NAME:buster-base $IMAGE_NAME:latest
if [ $PUSH = "TRUE" ]; then
    docker push $IMAGE_NAME:latest
fi