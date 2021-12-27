#!/bin/bash

# Check and create builder if neccesarry
if ! docker buildx ls | grep -q image-builder-worker; then
    echo "Builder alreddy exists"
    docker buildx use image-builder-worker
else
    echo "Creating builder"
    docker buildx create --name image-builder-worker --platform linux/amd64,linux/arm64,linux/arm/v7,linux/riscv64 --use
fi
