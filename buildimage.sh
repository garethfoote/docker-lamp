#!/bin/bash
VERSION=
if [ ! -z "$1" ]; then
    VERSION=":${1}"
fi

echo "Building ${VERSION}"
docker build -rm -t="garethfoote/lamp${VERSION}" .
